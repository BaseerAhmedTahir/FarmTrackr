-- enable uuid extension
create extension if not exists "uuid-ossp";

-- Create tables
create table caretakers (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  phone text,
  location text,
  payment_terms text,
  created_at timestamptz default now()
);

create table goats (
  id uuid primary key default uuid_generate_v4(),
  tag_id text unique,
  name text,
  photo_url text,
  purchase_price numeric(12,2),
  purchase_date date,
  caretaker_id uuid references caretakers(id),
  is_sold boolean default false,
  created_at timestamptz default now()
);

create table expenses (
  id uuid primary key default uuid_generate_v4(),
  goat_id uuid references goats(id) on delete cascade,
  amount numeric(12,2) not null,
  type text not null,
  notes text,
  expense_date timestamptz default now(),
  created_at timestamptz default now()
);

create table sales (
  id uuid primary key default uuid_generate_v4(),
  goat_id uuid references goats(id) on delete cascade,
  sale_price numeric(12,2) not null,
  sale_date timestamptz default now(),
  payment_mode text,
  created_at timestamptz default now()
);

create table weight_logs (
  id uuid primary key default uuid_generate_v4(),
  goat_id uuid references goats(id) on delete cascade,
  weight_kg numeric(6,2) not null,
  recorded_at timestamptz default now()
);

create table notifications (
  id uuid primary key default uuid_generate_v4(),
  message text not null,
  type text not null,
  record_id uuid,
  read boolean default false,
  created_at timestamptz default now()
);

-- Views
create or replace view v_goat_financials as
select
  g.id,
  g.tag_id,
  g.purchase_price,
  coalesce(sum(e.amount),0) as total_expense,
  s.sale_price,
  (coalesce(s.sale_price,0) - g.purchase_price - coalesce(sum(e.amount),0)) as net_profit
from goats g
left join expenses e on e.goat_id = g.id
left join sales s on s.goat_id = g.id
group by g.id, g.tag_id, g.purchase_price, s.sale_price;

-- RLS policies
alter table caretakers enable row level security;
alter table goats enable row level security;
alter table expenses enable row level security;
alter table sales enable row level security;
alter table weight_logs enable row level security;
alter table notifications enable row level security;

-- Investor (default) policies - full access
create policy "Full access for authenticated"
on caretakers for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Full access for authenticated"
on goats for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Full access for authenticated"
on expenses for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Full access for authenticated"
on sales for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Full access for authenticated"
on weight_logs for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

create policy "Full access for authenticated"
on notifications for all
using (auth.role() = 'authenticated')
with check (auth.role() = 'authenticated');

-- Caretaker specific policies
create policy "caretaker read own goats"
on goats for select
using (
  auth.jwt() ->> 'role' = 'caretaker'
  and caretaker_id = auth.uid()
);

create policy "caretaker add expense"
on expenses for insert
with check (
  auth.jwt() ->> 'role' = 'caretaker'
  and exists(select 1 from goats g where g.id = goat_id and g.caretaker_id = auth.uid())
);
