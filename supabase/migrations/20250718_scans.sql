-- Scans table for tracking QR/NFC scans
create table scans (
  id uuid primary key default uuid_generate_v4(),
  goat_id uuid references goats(id) on delete cascade,
  scan_type text not null check (scan_type in ('qr', 'nfc')),
  location text not null,
  notes text,
  scanned_at timestamptz default now()
);

-- security: caretaker can add/read own goats' scans
alter table scans enable row level security;

create policy "caretaker scan" on scans
  for all using (
    auth.role() = 'authenticated'
    and exists(
       select 1 from goats g
       where g.id = goat_id
         and (auth.jwt() ->> 'role' != 'caretaker' or g.caretaker_id = auth.uid())
    )
  ) with check (true);
