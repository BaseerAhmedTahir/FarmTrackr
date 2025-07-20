-- Create sales table and add necessary columns
BEGIN;

-- First ensure the UUID extension is available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create sales table if it doesn't exist
CREATE TABLE IF NOT EXISTS sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    sale_price DECIMAL NOT NULL,
    sale_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    buyer_name TEXT,
    buyer_contact TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_sales_updated_at ON sales;
CREATE TRIGGER update_sales_updated_at
    BEFORE UPDATE ON sales
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_sales_user_id ON sales(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_goat_id ON sales(goat_id);
CREATE INDEX IF NOT EXISTS idx_sales_sale_date ON sales(sale_date DESC);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON sales(created_at DESC);

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own sales" ON sales;
DROP POLICY IF EXISTS "Users can insert their own sales" ON sales;
DROP POLICY IF EXISTS "Users can update their own sales" ON sales;
DROP POLICY IF EXISTS "Users can delete their own sales" ON sales;

-- Enable RLS
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own sales"
ON sales FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own sales"
ON sales FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own sales"
ON sales FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own sales"
ON sales FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create or update the sales summary view
CREATE OR REPLACE VIEW sales_summary AS
SELECT 
    s.id,
    s.sale_date,
    s.created_at,
    s.updated_at,
    s.sale_price,
    s.buyer_name,
    s.buyer_contact,
    s.notes,
    g.name as goat_name,
    g.tag_number as goat_tag,
    g.purchase_price as goat_purchase_price,
    (s.sale_price - COALESCE(g.purchase_price, 0)) as profit,
    c.name as caretaker_name,
    u.email as user_email
FROM sales s
LEFT JOIN goats g ON s.goat_id = g.id
LEFT JOIN caretakers c ON g.caretaker_id = c.id
LEFT JOIN auth.users u ON s.user_id = u.id;

COMMIT;
