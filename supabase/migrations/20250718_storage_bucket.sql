-- Set up storage bucket
BEGIN;
SET LOCAL ROLE postgres;

-- Create storage bucket for goat photos if it doesn''t exist
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
VALUES (
    ''goat-photos'',
    ''Goat Photos'',
    false,
    false,
    52428800,  -- 50MB limit
    array[''image/jpeg'', ''image/png'', ''image/webp'']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    avif_autodetection = EXCLUDED.avif_autodetection,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

COMMIT;
