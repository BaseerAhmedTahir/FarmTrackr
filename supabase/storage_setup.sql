-- Storage setup for goat photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('goat-photos', 'goat-photos', false)
ON CONFLICT (id) DO UPDATE SET public = false;

-- Enable RLS on the bucket
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create policies for storage
DROP POLICY IF EXISTS "Allow authenticated users to view photos" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own photos" ON storage.objects;

-- Policy to allow authenticated users to view photos in their bucket
CREATE POLICY "Allow authenticated users to view photos"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'goat-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Policy to allow authenticated users to upload photos to their folder
CREATE POLICY "Allow authenticated users to upload photos"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'goat-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Create RLS policies for object ownership
CREATE POLICY "Users can update their own photos"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'goat-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'goat-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own photos"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'goat-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
