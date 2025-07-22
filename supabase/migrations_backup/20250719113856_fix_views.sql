-- Drop and recreate materialized view for financial data
DROP MATERIALIZED VIEW IF EXISTS public.v_goat_financials;

CREATE MATERIALIZED VIEW public.v_goat_financials AS
WITH expense_totals AS (
    SELECT goat_id, COALESCE(SUM(amount), 0) AS total_expenses
    FROM public.expenses
    GROUP BY goat_id
),
latest_sale AS (
    SELECT DISTINCT ON (goat_id) goat_id, sale_price, sale_date
    FROM public.sales
    ORDER BY goat_id, sale_date DESC
)
SELECT 
    g.id AS goat_id,
    g.tag_number,
    g.name,
    g.price AS purchase_price,
    s.sale_price,
    COALESCE(e.total_expenses, 0) AS expenses,
    (COALESCE(s.sale_price, 0) - COALESCE(g.price, 0) - COALESCE(e.total_expenses, 0)) AS profit,
    g.status::text,
    g.created_at,
    s.sale_date
FROM public.goats g
LEFT JOIN expense_totals e ON g.id = e.goat_id
LEFT JOIN latest_sale s ON g.id = s.goat_id;

-- Index for the view
CREATE UNIQUE INDEX IF NOT EXISTS idx_goat_financials_goat_id ON public.v_goat_financials (goat_id);

-- Refresh function
CREATE OR REPLACE FUNCTION refresh_goat_financials()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY public.v_goat_financials;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to refresh the view
DROP TRIGGER IF EXISTS refresh_goat_financials_on_expense ON public.expenses;
CREATE TRIGGER refresh_goat_financials_on_expense
    AFTER INSERT OR UPDATE OR DELETE ON public.expenses
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_goat_financials();

DROP TRIGGER IF EXISTS refresh_goat_financials_on_sale ON public.sales;
CREATE TRIGGER refresh_goat_financials_on_sale
    AFTER INSERT OR UPDATE OR DELETE ON public.sales
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_goat_financials();

DROP TRIGGER IF EXISTS refresh_goat_financials_on_goat ON public.goats;
CREATE TRIGGER refresh_goat_financials_on_goat
    AFTER INSERT OR UPDATE OR DELETE ON public.goats
    FOR EACH STATEMENT
    EXECUTE FUNCTION refresh_goat_financials();

-- Create or replace caretaker summary view
DROP VIEW IF EXISTS v_caretaker_summary;

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
    SUM(CASE WHEN g.status = 'sold' THEN g.price ELSE 0 END) as total_profit,
    ROUND(SUM(CASE WHEN g.status = 'sold' THEN g.price * (c.profit_share / 100) ELSE 0 END), 2) as profit_share_amount
FROM 
    caretakers c
    LEFT JOIN goats g ON g.caretaker_id = c.id
    LEFT JOIN expense_totals et ON et.caretaker_id = c.id
GROUP BY 
    c.id, c.name, c.profit_share, c.created_at, et.total_expenses, et.goats_with_expenses;
