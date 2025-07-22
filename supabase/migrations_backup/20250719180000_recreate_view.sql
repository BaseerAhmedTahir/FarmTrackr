-- Drop the view if it exists
DROP VIEW IF EXISTS public.v_goat_financials CASCADE;

-- Create the view
CREATE OR REPLACE VIEW public.v_goat_financials AS
SELECT 
    g.id,
    g.name as tag_number,
    g.created_at as purchase_date,
    g.price as purchase_price,
    g.status,
    g.gender,
    g.breed,
    COALESCE(s.sale_price, 0) as sale_price,
    s.sale_date,
    s.buyer_name,
    s.buyer_contact,
    COALESCE((
        SELECT SUM(e.amount)
        FROM public.expenses e
        WHERE e.goat_id = g.id
    ), 0) as total_expenses,
    CASE 
        WHEN s.sale_price IS NOT NULL THEN 
            s.sale_price - g.price - COALESCE((
                SELECT SUM(e.amount)
                FROM public.expenses e
                WHERE e.goat_id = g.id
            ), 0)
        ELSE 
            -g.price - COALESCE((
                SELECT SUM(e.amount)
                FROM public.expenses e
                WHERE e.goat_id = g.id
            ), 0)
    END as net_profit
FROM 
    public.goats g
LEFT JOIN 
    public.sales s ON g.id = s.goat_id;

-- Grant all necessary permissions
GRANT ALL ON public.v_goat_financials TO authenticated;
GRANT ALL ON public.v_goat_financials TO service_role;
GRANT ALL ON public.v_goat_financials TO anon;
