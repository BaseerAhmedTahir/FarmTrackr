-- Drop the views if they exist
DROP MATERIALIZED VIEW IF EXISTS public.v_goat_financials;
DROP VIEW IF EXISTS public.v_goat_financials;

-- Create the financial summary view
CREATE VIEW public.v_goat_financials AS
WITH expense_sums AS (
    SELECT 
        goat_id,
        SUM(amount) as total_expense
    FROM public.expenses
    GROUP BY goat_id
),
sales_data AS (
    SELECT 
        goat_id,
        sale_price,
        sale_date
    FROM public.sales
)
SELECT 
    g.id,
    g.tag_number,
    g.name,
    g.price,
    g.status,
    g.user_id,
    COALESCE(e.total_expense, 0) as total_expense,
    s.sale_price,
    s.sale_date,
    CASE 
        WHEN s.sale_price IS NOT NULL 
        THEN s.sale_price - (g.price + COALESCE(e.total_expense, 0))
        ELSE NULL
    END as profit
FROM public.goats g
LEFT JOIN expense_sums e ON g.id = e.goat_id
LEFT JOIN sales_data s ON g.id = s.goat_id;

-- Grant permissions
GRANT SELECT ON public.v_goat_financials TO authenticated;

-- Create a policy to restrict access to user's own data
CREATE POLICY "Users can only view their own financial data"
    ON public.v_goat_financials
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Create or replace function for calculating summary
CREATE OR REPLACE FUNCTION public.get_financial_summary(user_id_param uuid)
RETURNS TABLE (
    count bigint,
    invested decimal,
    sales decimal,
    profit decimal
) AS $$
BEGIN
    RETURN QUERY
    WITH user_goats AS (
        SELECT 
            g.id,
            g.price,
            g.status,
            COALESCE(e.total_expense, 0) as total_expense,
            s.sale_price
        FROM public.goats g
        LEFT JOIN (
            SELECT goat_id, SUM(amount) as total_expense
            FROM public.expenses
            GROUP BY goat_id
        ) e ON g.id = e.goat_id
        LEFT JOIN public.sales s ON g.id = s.goat_id
        WHERE g.user_id = user_id_param
    )
    SELECT 
        COUNT(*)::bigint,
        COALESCE(SUM(price), 0)::decimal,
        COALESCE(SUM(CASE WHEN status = 'sold' THEN sale_price ELSE 0 END), 0)::decimal,
        COALESCE(SUM(CASE 
            WHEN status = 'sold' 
            THEN sale_price - (price + total_expense)
            ELSE 0
        END), 0)::decimal
    FROM user_goats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.get_financial_summary(uuid) TO authenticated;
