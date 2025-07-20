-- Before anything else, check if we need to backup the schema content first
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'storage'
        AND table_name = 'objects'
    ) THEN
        CREATE TABLE IF NOT EXISTS storage_backup.objects AS SELECT * FROM storage.objects;
        CREATE TABLE IF NOT EXISTS storage_backup.buckets AS SELECT * FROM storage.buckets;
    END IF;
END $$;
DROP SCHEMA IF EXISTS storage CASCADE;

-- Create the storage schema
CREATE SCHEMA storage;

-- Create the buckets table
CREATE TABLE storage.buckets (
  id text primary key,
  name text not null,
  owner uuid references auth.users not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  public boolean not null default false,
  type text not null default 'DEFAULT',
  file_size_limit bigint,
  allowed_mime_types text[]
);

-- Create the objects table
CREATE TABLE storage.objects (
  id uuid primary key DEFAULT extensions.uuid_generate_v4(),
  bucket_id text references storage.buckets,
  name text,
  owner uuid references auth.users,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  last_accessed_at timestamptz default now(),
  metadata jsonb,
  path_tokens text[] generated always as (string_to_array(name, '/')) stored
);

-- Create analytics tables
CREATE TABLE storage.buckets_analytics (
  id text primary key,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Setup RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- Create the goat-photos bucket
INSERT INTO storage.buckets (id, name, public, owner)
SELECT 'goat-photos', 'goat-photos', false, (SELECT id FROM auth.users LIMIT 1)
WHERE NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'goat-photos');

-- Create policies
CREATE POLICY "Allow authenticated users to view photos"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'goat-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Allow authenticated users to upload photos"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (bucket_id = 'goat-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update their own photos"
ON storage.objects FOR UPDATE TO authenticated
USING (bucket_id = 'goat-photos' AND auth.uid()::text = (storage.foldername(name))[1])
WITH CHECK (bucket_id = 'goat-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete their own photos"
ON storage.objects FOR DELETE TO authenticated
USING (bucket_id = 'goat-photos' AND auth.uid()::text = (storage.foldername(name))[1]);
