-- Drop all existing policies on expenses table
DROP POLICY IF EXISTS "Users can add expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can view their expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can insert expenses" ON public.expenses;

-- Add profit_share column to caretakers
ALTER TABLE caretakers ADD COLUMN IF NOT EXISTS profit_share DECIMAL DEFAULT 0;

-- Create caretaker summary view
CREATE OR REPLACE VIEW v_caretaker_summary AS
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
    c.updated_at,
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
    c.id, c.name, c.profit_share, c.created_at, c.updated_at, et.total_expenses, et.goats_with_expenses;

-- Recreate expense policies
CREATE POLICY "Users can add expenses"
ON public.expenses
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() IN (
        SELECT user_id
        FROM goats
        WHERE id = goat_id
    )
);

CREATE POLICY "Users can view their expenses"
ON public.expenses
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
    auth.uid() IN (
        SELECT user_id
        FROM goats
        WHERE id = goat_id
    )
);
