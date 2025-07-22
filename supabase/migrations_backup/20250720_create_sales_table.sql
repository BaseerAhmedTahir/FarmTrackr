-- Create sales table and add necessary columns
BEGIN;

-- First ensure the UUID extension is available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop dependent views first
DROP VIEW IF EXISTS sales_summary;
DROP VIEW IF EXISTS v_goat_financials;
DROP VIEW IF EXISTS expense_summary CASCADE;
DROP VIEW IF EXISTS caretaker_summary CASCADE;

-- Drop and recreate the sales table
DROP TABLE IF EXISTS sales CASCADE;
CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    sale_price DECIMAL NOT NULL,
    sale_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    buyer_name TEXT,
    buyer_contact TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

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
    s.sale_price,
    s.buyer_name,
    s.buyer_contact,
    s.notes,
    g.name as goat_name,
    g.tag_number as goat_tag,
    g.price as goat_purchase_price,
    (s.sale_price - COALESCE(g.price, 0)) as profit,
    c.name as caretaker_name,
    u.email as user_email
FROM sales s
LEFT JOIN goats g ON s.goat_id = g.id
LEFT JOIN caretakers c ON g.caretaker_id = c.id
LEFT JOIN auth.users u ON s.user_id = u.id;

-- Recreate the goat financials view
CREATE OR REPLACE VIEW v_goat_financials AS
SELECT
    g.id,
    g.name,
    g.tag_number,
    g.price as purchase_price,
    COALESCE(s.sale_price, 0) as sale_price,
    COALESCE(s.sale_price - g.price, 0) as profit,
    COALESCE(e.total_expenses, 0) as total_expenses,
    COALESCE(s.sale_price - g.price - e.total_expenses, -g.price - COALESCE(e.total_expenses, 0)) as net_profit
FROM goats g
LEFT JOIN sales s ON g.id = s.goat_id
LEFT JOIN (
    SELECT goat_id, SUM(amount) as total_expenses
    FROM expenses
    GROUP BY goat_id
) e ON g.id = e.goat_id;

-- Recreate caretaker summary view
CREATE OR REPLACE VIEW caretaker_summary AS
SELECT
    c.id,
    c.name,
    c.phone as contact,
    COUNT(DISTINCT g.id) as total_goats,
    COALESCE(SUM(g.price), 0) as total_investment,
    COALESCE(SUM(CASE WHEN s.id IS NOT NULL THEN s.sale_price ELSE 0 END), 0) as total_sales,
    COALESCE(SUM(CASE WHEN s.id IS NOT NULL THEN s.sale_price - g.price ELSE 0 END), 0) as gross_profit,
    COALESCE(SUM(e.total_expenses), 0) as total_expenses,
    COALESCE(SUM(CASE WHEN s.id IS NOT NULL THEN s.sale_price - g.price ELSE 0 END), 0) - COALESCE(SUM(e.total_expenses), 0) as net_profit
FROM caretakers c
LEFT JOIN goats g ON c.id = g.caretaker_id
LEFT JOIN sales s ON g.id = s.goat_id
LEFT JOIN (
    SELECT goat_id, SUM(amount) as total_expenses
    FROM expenses
    GROUP BY goat_id
) e ON g.id = e.goat_id
GROUP BY c.id, c.name, c.phone;

-- Recreate expense summary view
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

COMMIT;
