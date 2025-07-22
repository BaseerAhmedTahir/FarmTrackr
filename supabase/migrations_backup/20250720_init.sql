-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- Create tables
create table if not exists profiles (
  id uuid references auth.users on delete cascade,
  email text unique not null,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (id)
);

create table if not exists goats (
  id uuid default uuid_generate_v4() primary key,
  tag_number text unique not null,
  name text not null,
  breed text not null,
  birth_date date not null,
  purchase_price decimal not null,
  purchase_date date not null,
  purchase_from text,
  photo_url text,
  qr_url text,
  caretaker_id uuid references profiles(id),
  user_id uuid references profiles(id) not null,
  gender text check (gender in ('male', 'female', 'unknown')) default 'unknown',
  status text check (status in ('active', 'sold', 'dead')) default 'active',
  sale_price decimal,
  sale_date timestamp with time zone,
  buyer_info text,
  weight_history jsonb default '[]'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists expenses (
  id uuid default uuid_generate_v4() primary key,
  type text check (type in ('feed', 'medicine', 'transport', 'other')) not null,
  amount decimal not null,
  goat_id uuid references goats(id) on delete cascade,
  notes text,
  user_id uuid references profiles(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table if not exists caretakers (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  contact text,
  location text,
  payment_type text check (payment_type in ('fixed', 'share')) not null,
  profit_share_pct decimal check (
    (payment_type = 'share' and profit_share_pct is not null) or 
    (payment_type = 'fixed' and profit_share_pct is null)
  ),
  monthly_fee decimal check (
    (payment_type = 'fixed' and monthly_fee is not null) or 
    (payment_type = 'share' and monthly_fee is null)
  ),
  user_id uuid references profiles(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes
create index if not exists goats_tag_number_idx on goats (tag_number);
create index if not exists goats_caretaker_id_idx on goats (caretaker_id);
create index if not exists goats_status_idx on goats (status);
create index if not exists expenses_goat_id_idx on expenses (goat_id);
create index if not exists expenses_type_idx on expenses (type);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;
alter table goats enable row level security;
alter table expenses enable row level security;
alter table caretakers enable row level security;

-- Create policies
create policy "Public profiles are viewable by user"
  on profiles for select
  using (true);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- Goat policies
create policy "Users can view their own goats"
  on goats for select
  using (auth.uid() = user_id);

create policy "Users can insert their own goats"
  on goats for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own goats"
  on goats for update
  using (auth.uid() = user_id);

create policy "Users can delete their own goats"
  on goats for delete
  using (auth.uid() = user_id);

-- Expense policies
create policy "Users can view their own expenses"
  on expenses for select
  using (auth.uid() = user_id);

create policy "Users can insert their own expenses"
  on expenses for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own expenses"
  on expenses for update
  using (auth.uid() = user_id);

create policy "Users can delete their own expenses"
  on expenses for delete
  using (auth.uid() = user_id);

-- Caretaker policies
create policy "Users can view their own caretakers"
  on caretakers for select
  using (auth.uid() = user_id);

create policy "Users can insert their own caretakers"
  on caretakers for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own caretakers"
  on caretakers for update
  using (auth.uid() = user_id);

create policy "Users can delete their own caretakers"
  on caretakers for delete
  using (auth.uid() = user_id);
