-- Set up storage permissions
BEGIN;
SET LOCAL ROLE postgres;

-- Create or update storage schema if needed
CREATE SCHEMA IF NOT EXISTS storage;

-- Enable row level security for storage
ALTER TABLE IF EXISTS storage.objects ENABLE ROW LEVEL SECURITY;

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
