-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create the goats table first
CREATE TABLE IF NOT EXISTS public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    breed VARCHAR,
    gender VARCHAR NOT NULL,
    birth_date DATE,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    status VARCHAR NOT NULL DEFAULT 'active',
    notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create RLS policy for goats
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own goats"
    ON public.goats
    FOR ALL
    USING (auth.uid() = user_id);

-- Then create the expenses table with foreign key to goats
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type VARCHAR NOT NULL,
    notes TEXT DEFAULT '',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create RLS policy for expenses
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own expenses"
    ON public.expenses
    FOR ALL
    USING (auth.uid() = user_id);

-- Create the sales table
CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    sale_price DECIMAL(10,2) NOT NULL CHECK (sale_price >= 0),
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    buyer_name VARCHAR NOT NULL,
    buyer_contact VARCHAR,
    notes TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create RLS policy for sales
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own sales"
    ON public.sales
    FOR ALL
    USING (auth.uid() = user_id);

-- Create the financial summary view
CREATE OR REPLACE FUNCTION public.get_financial_summary_v2(user_id_param uuid)
RETURNS TABLE (
    count integer,
    invested numeric,
    sales numeric,
    profit numeric
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    WITH expense_sums AS (
        SELECT 
            goat_id,
            SUM(amount) as total_expense
        FROM expenses
        GROUP BY goat_id
    ),
    sales_sums AS (
        SELECT
            g.user_id,
            COUNT(g.id) as total_goats,
            COALESCE(SUM(g.price), 0) as total_invested,
            COALESCE(SUM(s.sale_price), 0) as total_sales,
            COALESCE(SUM(
                CASE 
                    WHEN s.sale_price IS NOT NULL 
                    THEN s.sale_price - (g.price + COALESCE(e.total_expense, 0))
                    ELSE 0
                END
            ), 0) as total_profit
        FROM goats g
        LEFT JOIN sales s ON g.id = s.goat_id
        LEFT JOIN expense_sums e ON g.id = e.goat_id
        WHERE g.user_id = user_id_param
        GROUP BY g.user_id
    )
    SELECT
        COALESCE(total_goats, 0)::integer as count,
        COALESCE(total_invested, 0)::numeric as invested,
        COALESCE(total_sales, 0)::numeric as sales,
        COALESCE(total_profit, 0)::numeric as profit
    FROM sales_sums
    WHERE user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_financial_summary_v2(uuid) TO authenticated;
