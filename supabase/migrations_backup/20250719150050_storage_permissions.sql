-- Ensure storage schema exists and we have permissions
DO $$
BEGIN
    -- Try to create schema if not exists
    CREATE SCHEMA IF NOT EXISTS storage;

    -- Grant usage to service role
    GRANT USAGE ON SCHEMA storage TO service_role;
    GRANT ALL ON ALL TABLES IN SCHEMA storage TO service_role;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO service_role;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA storage TO service_role;

    -- Grant usage to authenticated users
    GRANT USAGE ON SCHEMA storage TO authenticated;
    GRANT ALL ON ALL TABLES IN SCHEMA storage TO authenticated;
    GRANT ALL ON ALL SEQUENCES IN SCHEMA storage TO authenticated;
    GRANT ALL ON ALL FUNCTIONS IN SCHEMA storage TO authenticated;

END $$;
