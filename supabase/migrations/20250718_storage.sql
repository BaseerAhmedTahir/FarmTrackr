-- Set up storage -- Drop existing policies
DROP POLICY IF EXISTS "Authenticated users can upload goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their goat photos" ON storage.objects;ons
BEGIN;

-- Switch to superuser role
SET ROLE postgres;

-- Create or update storage schema if needed
CREATE SCHEMA IF NOT EXISTS storage AUTHORIZATION postgres;

-- Grant usage on storage schema
GRANT USAGE ON SCHEMA storage TO postgres, authenticated, anon;
GRANT ALL ON SCHEMA storage TO postgres;

-- Grant access to storage.objects
GRANT ALL ON storage.objects TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON storage.objects TO authenticated;
GRANT SELECT ON storage.objects TO anon;

-- Enable row level security for storage
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Authenticated users can upload goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their goat photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their goat photos" ON storage.objects;

-- Storage policies
CREATE POLICY "Authenticated users can upload goat photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'goat-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view their goat photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'goat-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update their goat photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'goat-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'goat-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own photos
CREATE POLICY "Users can delete their goat photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'goat-photos' AND
    (storage.foldername(name))[1] = auth.uid()::text
);

-- Create bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('goat-photos', 'Goat Photos', false)
ON CONFLICT (id) DO NOTHING;

COMMIT;
