-- Fix sales table and add necessary columns
BEGIN;

-- Drop existing constraints and indexes to avoid conflicts
DROP INDEX IF EXISTS idx_sales_date;
DROP INDEX IF EXISTS idx_sales_created_at;

-- Safely handle column changes
DO $$
DECLARE
    temp_created_at TIMESTAMPTZ;
BEGIN
    -- Backup created_at data if it exists
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='sales' AND column_name='created_at') THEN
        CREATE TEMP TABLE IF NOT EXISTS temp_timestamps AS
        SELECT id, created_at FROM sales;
    END IF;

    -- Check if columns exist before attempting to drop
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='sales' AND column_name='date') THEN
        ALTER TABLE sales DROP COLUMN date;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='sales' AND column_name='created_at') THEN
        ALTER TABLE sales DROP COLUMN created_at;
    END IF;

    -- Add new columns if they don't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'sale_date') THEN
        ALTER TABLE sales ADD COLUMN sale_date TIMESTAMPTZ NOT NULL DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'created_at') THEN
        ALTER TABLE sales ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'sale_price') THEN
        ALTER TABLE sales ADD COLUMN sale_price DECIMAL NOT NULL DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'buyer_name') THEN
        ALTER TABLE sales ADD COLUMN buyer_name TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'buyer_contact') THEN
        ALTER TABLE sales ADD COLUMN buyer_contact TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'notes') THEN
        ALTER TABLE sales ADD COLUMN notes TEXT;
    END IF;

    -- Restore created_at data if it existed
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'temp_timestamps') THEN
        UPDATE sales s
        SET created_at = t.created_at
        FROM temp_timestamps t
        WHERE s.id = t.id;
        
        DROP TABLE temp_timestamps;
    END IF;
END $$;

-- Create or update indexes
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date DESC);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sales_goat ON sales(goat_id);

-- Add RLS policies for sales table
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Policy for viewing sales - users can only see their own sales
CREATE POLICY "Users can view their own sales"
ON sales FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy for inserting sales - users can only insert their own sales
CREATE POLICY "Users can insert their own sales"
ON sales FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy for updating sales - users can only update their own sales
CREATE POLICY "Users can update their own sales"
ON sales FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy for deleting sales - users can only delete their own sales
CREATE POLICY "Users can delete their own sales"
ON sales FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create sales summary view
CREATE OR REPLACE VIEW sales_summary AS
SELECT 
    s.id,
    s.sale_date,
    s.created_at,
    s.sale_price,
    s.buyer_name,
    s.buyer_contact,
    s.notes,
    g.name as goat_name,
    g.tag_number as goat_tag,
    g.purchase_price as goat_purchase_price,
    (s.sale_price - COALESCE(g.purchase_price, 0)) as profit,
    c.name as caretaker_name
FROM sales s
LEFT JOIN goats g ON s.goat_id = g.id
LEFT JOIN caretakers c ON g.caretaker_id = c.id;

COMMIT;
