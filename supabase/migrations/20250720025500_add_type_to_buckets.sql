-- Backup storage data
DO $$
BEGIN
    CREATE SCHEMA IF NOT EXISTS storage_backup;
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'storage'
        AND table_name = 'buckets'
    ) THEN
        CREATE TABLE storage_backup.buckets AS SELECT * FROM storage.buckets;
    END IF;
END
$$;

-- Add type column if it doesn't exist
DO $$
BEGIN
    -- Check if type column exists
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'storage'
        AND table_name = 'buckets'
        AND column_name = 'type'
    ) THEN
        -- Add type column
        ALTER TABLE storage.buckets ADD COLUMN type text NOT NULL DEFAULT 'DEFAULT';
    END IF;
END
$$;

-- Restore backed up data if needed
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'storage_backup'
        AND table_name = 'buckets'
    ) THEN
        -- Delete any existing data first
        DELETE FROM storage.buckets;
        
        -- Insert backed up data
        INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, file_size_limit, allowed_mime_types)
        SELECT id, name, owner, created_at, updated_at, public, file_size_limit, allowed_mime_types
        FROM storage_backup.buckets;
        
        -- Drop backup schema
        DROP SCHEMA storage_backup CASCADE;
    END IF;
END
$$;
