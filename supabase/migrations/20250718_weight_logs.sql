-- Weight logs table
create table weight_logs (
  id uuid primary key default uuid_generate_v4(),
  goat_id uuid references goats(id) on delete cascade,
  weight_kg numeric(6,2) not null,
  recorded_at timestamptz default now()
);

-- security: caretaker can add/read own goats' weight
alter table weight_logs enable row level security;

create policy "caretaker weight" on weight_logs
  for all using (
    auth.role() = 'authenticated'
    and exists(
       select 1 from goats g
       where g.id = goat_id
         and (auth.jwt() ->> 'role' != 'caretaker' or g.caretaker_id = auth.uid())
    )
  ) with check (true);
