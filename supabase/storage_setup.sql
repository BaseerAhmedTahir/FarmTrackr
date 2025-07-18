-- This migration needs to be run as storage admin
BEGIN;

-- Storage setup
DO $$ 
BEGIN
    -- Create storage bucket for goat photos if it doesn't exist
    INSERT INTO storage.buckets (id, name, public)
    VALUES ('goat-photos', 'goat-photos', false)
    ON CONFLICT (id) DO NOTHING;

    -- Enable RLS for storage
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can upload goat photos" ON storage.objects;
    DROP POLICY IF EXISTS "Users can access own goat photos" ON storage.objects;
    DROP POLICY IF EXISTS "Users can update own goat photos" ON storage.objects;
    DROP POLICY IF EXISTS "Users can delete own goat photos" ON storage.objects;

    -- Create storage policies
    CREATE POLICY "Users can upload goat photos" ON storage.objects
        FOR INSERT
        TO authenticated
        WITH CHECK (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

    CREATE POLICY "Users can access own goat photos" ON storage.objects
        FOR SELECT
        TO authenticated
        USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

    CREATE POLICY "Users can update own goat photos" ON storage.objects
        FOR UPDATE
        TO authenticated
        USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text)
        WITH CHECK (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

    CREATE POLICY "Users can delete own goat photos" ON storage.objects
        FOR DELETE
        TO authenticated
        USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error setting up storage: %', SQLERRM;
        RAISE;
END $$;

COMMIT;
