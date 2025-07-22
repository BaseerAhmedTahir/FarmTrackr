-- Add profit_share column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'caretakers' 
        AND column_name = 'profit_share'
    ) THEN
        ALTER TABLE caretakers ADD COLUMN profit_share DECIMAL DEFAULT 0;
    END IF;
END $$;

-- Drop view if exists
DROP VIEW IF EXISTS v_caretaker_summary;

-- Create the view
CREATE VIEW v_caretaker_summary AS
WITH expense_totals AS (
    SELECT 
        c.id as caretaker_id,
        COALESCE(SUM(e.amount), 0) as total_expenses,
        COUNT(DISTINCT e.goat_id) as goats_with_expenses
    FROM 
        caretakers c
        LEFT JOIN goats g ON g.caretaker_id = c.id
        LEFT JOIN expenses e ON e.goat_id = g.id
    GROUP BY c.id
)
SELECT 
    c.id,
    c.name,
    c.profit_share,
    c.created_at,
    COALESCE(et.total_expenses, 0) as total_expenses,
    COALESCE(et.goats_with_expenses, 0) as goats_with_expenses,
    COUNT(DISTINCT g.id) as total_goats,
    SUM(CASE WHEN g.status = 'sold' THEN g.sale_price - g.purchase_price ELSE 0 END) as total_profit,
    ROUND(SUM(CASE WHEN g.status = 'sold' THEN (g.sale_price - g.purchase_price) * (c.profit_share / 100) ELSE 0 END), 2) as profit_share_amount
FROM 
    caretakers c
    LEFT JOIN goats g ON g.caretaker_id = c.id
    LEFT JOIN expense_totals et ON et.caretaker_id = c.id
GROUP BY 
    c.id, c.name, c.profit_share, c.created_at, et.total_expenses, et.goats_with_expenses;
