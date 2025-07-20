-- Comprehensive expense table fixes
BEGIN;

-- First create the UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create UUID validation function
CREATE OR REPLACE FUNCTION is_uuid(text)
RETURNS boolean AS $$
BEGIN
    RETURN $1 ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Drop existing constraints and indexes to avoid conflicts
DROP INDEX IF EXISTS idx_expenses_date;
DROP INDEX IF EXISTS idx_expenses_created_at;

-- Ensure expense_type enum exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'expense_type') THEN
        CREATE TYPE expense_type AS ENUM ('feed', 'medicine', 'transport', 'other');
    END IF;
END $$;

-- Drop dependent views first
DROP VIEW IF EXISTS expense_summary CASCADE;

-- Safely handle column changes
DO $$
DECLARE
    temp_created_at TIMESTAMPTZ;
BEGIN
    -- Backup created_at data if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='expenses' AND column_name='created_at') THEN
        CREATE TEMP TABLE IF NOT EXISTS temp_timestamps AS
        SELECT id, created_at FROM expenses;
    END IF;

    -- Check if columns exist before attempting to drop
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='expenses' AND column_name='date') THEN
        ALTER TABLE expenses DROP COLUMN date;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='expenses' AND column_name='created_at') THEN
        ALTER TABLE expenses DROP COLUMN created_at;
    END IF;

    -- Add new columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='expenses' AND column_name='expense_date') THEN
        ALTER TABLE expenses 
            ADD COLUMN expense_date TIMESTAMPTZ NOT NULL DEFAULT NOW();
    END IF;

    -- Add created_at back
    ALTER TABLE expenses 
        ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

    -- Restore created_at data if it existed
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'temp_timestamps') THEN
        UPDATE expenses e
        SET created_at = t.created_at
        FROM temp_timestamps t
        WHERE e.id = t.id;
        
        DROP TABLE temp_timestamps;
    END IF;
END $$;

-- Add UUID validation trigger
CREATE OR REPLACE FUNCTION validate_uuid()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.id IS NULL OR NOT is_uuid(NEW.id::text) THEN
        NEW.id := uuid_generate_v4();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ensure_expense_uuid ON expenses;
CREATE TRIGGER ensure_expense_uuid
    BEFORE INSERT ON expenses
    FOR EACH ROW
    EXECUTE FUNCTION validate_uuid();

-- Create or update indexes
CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON expenses(expense_date DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_expenses_goat ON expenses(goat_id);
CREATE INDEX IF NOT EXISTS idx_expenses_type ON expenses(type);

-- Create expense views
CREATE OR REPLACE VIEW expense_summary AS
SELECT 
    e.id,
    e.type,
    e.amount,
    e.expense_date,
    e.created_at,
    e.notes,
    g.name as goat_name,
    g.tag_number as goat_tag,
    c.name as caretaker_name
FROM expenses e
LEFT JOIN goats g ON e.goat_id = g.id
LEFT JOIN caretakers c ON g.caretaker_id = c.id;

-- Create view for goat total expenses
CREATE OR REPLACE VIEW goat_expenses AS
SELECT 
    g.id,
    g.name,
    g.tag_number,
    COALESCE(SUM(e.amount), 0) as total_expense,
    COUNT(e.id) as expense_count
FROM goats g
LEFT JOIN expenses e ON g.id = e.goat_id
GROUP BY g.id, g.name, g.tag_number;

-- Add RLS policies for expenses table
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Policy for viewing expenses - users can only see their own expenses
CREATE POLICY "Users can view their own expenses"
ON expenses FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy for inserting expenses - users can only insert their own expenses
CREATE POLICY "Users can insert their own expenses"
ON expenses FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy for updating expenses - users can only update their own expenses
CREATE POLICY "Users can update their own expenses"
ON expenses FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy for deleting expenses - users can only delete their own expenses
CREATE POLICY "Users can delete their own expenses"
ON expenses FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Ensure expenses table has all required columns
DO $$ 
BEGIN
    -- Add columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'id') THEN
        ALTER TABLE expenses ADD COLUMN id UUID PRIMARY KEY DEFAULT uuid_generate_v4();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'type') THEN
        ALTER TABLE expenses ADD COLUMN type expense_type NOT NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'amount') THEN
        ALTER TABLE expenses ADD COLUMN amount DECIMAL NOT NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'goat_id') THEN
        ALTER TABLE expenses ADD COLUMN goat_id UUID REFERENCES goats(id) ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'user_id') THEN
        ALTER TABLE expenses ADD COLUMN user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'expenses' AND column_name = 'notes') THEN
        ALTER TABLE expenses ADD COLUMN notes TEXT;
    END IF;
END $$;

COMMIT;