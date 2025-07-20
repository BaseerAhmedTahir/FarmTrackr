-- Create caretaker summary view
CREATE OR REPLACE VIEW public.v_caretaker_summary AS
WITH goat_stats AS (
    SELECT 
        g.caretaker_id,
        COUNT(g.id) as goat_count,
        COALESCE(SUM(g.price), 0) as total_investment,
        COALESCE(SUM(e.amount), 0) as total_expenses,
        COALESCE(SUM(s.sale_price), 0) as total_sales,
        COALESCE(SUM(
            CASE 
                WHEN s.sale_price IS NOT NULL 
                THEN (s.sale_price - g.price - COALESCE(e.amount, 0)) * (c.profit_share / 100.0)
                ELSE 0
            END
        ), 0) as profit_share
    FROM public.caretakers c
    LEFT JOIN public.goats g ON g.caretaker_id = c.id
    LEFT JOIN (
        SELECT goat_id, SUM(amount) as amount
        FROM public.expenses
        GROUP BY goat_id
    ) e ON e.goat_id = g.id
    LEFT JOIN public.sales s ON s.goat_id = g.id
    GROUP BY g.caretaker_id
)
SELECT 
    c.id,
    c.name,
    c.phone,
    c.location,
    c.profit_share,
    COALESCE(gs.goat_count, 0) as goat_count,
    COALESCE(gs.total_investment, 0) as total_investment,
    COALESCE(gs.total_expenses, 0) as total_expenses,
    COALESCE(gs.total_sales, 0) as total_sales,
    COALESCE(gs.profit_share, 0) as profit_share
FROM public.caretakers c
LEFT JOIN goat_stats gs ON gs.caretaker_id = c.id;

-- Add necessary index for better performance
CREATE INDEX IF NOT EXISTS idx_goats_caretaker_id ON public.goats(caretaker_id);
