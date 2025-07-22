-- Drop the view if it exists
DROP VIEW IF EXISTS public.v_goat_financials CASCADE;

-- Ensure tables exist
CREATE TABLE IF NOT EXISTS public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    price DECIMAL NOT NULL,
    status TEXT NOT NULL,
    gender TEXT NOT NULL,
    breed TEXT
);

CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    sale_price DECIMAL NOT NULL,
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    buyer_name TEXT,
    buyer_contact TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    amount DECIMAL NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
GRANT ALL ON public.goats TO authenticated;
GRANT ALL ON public.goats TO service_role;
GRANT ALL ON public.goats TO anon;

GRANT ALL ON public.sales TO authenticated;
GRANT ALL ON public.sales TO service_role;
GRANT ALL ON public.sales TO anon;

GRANT ALL ON public.expenses TO authenticated;
GRANT ALL ON public.expenses TO service_role;
GRANT ALL ON public.expenses TO anon;

GRANT ALL ON public.v_goat_financials TO authenticated;
GRANT ALL ON public.v_goat_financials TO service_role;
GRANT ALL ON public.v_goat_financials TO anon;
