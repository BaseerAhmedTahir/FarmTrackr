-- Drop and recreate materialized view for financial data
DROP MATERIALIZED VIEW IF EXISTS public.v_goat_financials CASCADE;

-- Drop existing tables to ensure clean schema
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.scans CASCADE;
DROP TABLE IF EXISTS public.weight_logs CASCADE;
DROP TABLE IF EXISTS public.sales CASCADE;
DROP TABLE IF EXISTS public.expenses CASCADE;
DROP TABLE IF EXISTS public.goats CASCADE;
DROP TABLE IF EXISTS public.caretakers CASCADE;

-- Create caretakers table
CREATE TABLE public.caretakers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    phone VARCHAR,
    location VARCHAR,
    payment_terms VARCHAR,
    profit_share DECIMAL DEFAULT 0,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create goats table
CREATE TABLE public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    birth_date TIMESTAMP WITH TIME ZONE,
    price DECIMAL(10,2) CHECK (price >= 0),
    photo_url TEXT,
    status VARCHAR DEFAULT 'active',
    caretaker_id UUID REFERENCES public.caretakers(id) ON DELETE SET NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(user_id, tag_number)
);

-- Create expenses table
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type VARCHAR NOT NULL,
    notes TEXT DEFAULT '',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create sales table
CREATE TABLE public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    sale_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

-- Create goat financials view
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

-- Create caretaker summary view
CREATE VIEW v_caretaker_summary AS
WITH goat_data AS (
    SELECT 
        c.id as caretaker_id,
        COUNT(DISTINCT g.id) as total_goats,
        COALESCE(SUM(g.price), 0) as total_investment,
        COALESCE(SUM(CASE WHEN g.status = 'sold' THEN g.price ELSE 0 END), 0) as sold_investment
    FROM 
        caretakers c
        LEFT JOIN goats g ON g.caretaker_id = c.id
    GROUP BY c.id
),
expense_totals AS (
    SELECT 
        c.id as caretaker_id,
        COALESCE(SUM(e.amount), 0) as total_expenses
    FROM 
        caretakers c
        LEFT JOIN goats g ON g.caretaker_id = c.id
        LEFT JOIN expenses e ON e.goat_id = g.id
    GROUP BY c.id
)
SELECT 
    c.id,
    c.name,
    c.phone,
    c.location,
    COALESCE(c.profit_share, 0) as profit_share,
    c.created_at,
    COALESCE(gd.total_goats, 0) as total_goats,
    COALESCE(gd.total_investment, 0) as total_investment,
    COALESCE(gd.sold_investment, 0) as sold_investment,
    COALESCE(et.total_expenses, 0) as total_expenses,
    ROUND(COALESCE(gd.sold_investment, 0) * COALESCE(c.profit_share, 0) / 100, 2) as profit_share_amount
FROM 
    caretakers c
    LEFT JOIN goat_data gd ON gd.caretaker_id = c.id
    LEFT JOIN expense_totals et ON et.caretaker_id = c.id;

-- Enable RLS on all tables
ALTER TABLE public.caretakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

-- Add RLS policies
CREATE POLICY "Users can view all caretakers"
ON public.caretakers FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can manage caretakers"
ON public.caretakers FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their goats"
ON public.goats FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can manage their goats"
ON public.goats FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view their expenses"
ON public.expenses FOR SELECT
TO authenticated
USING (
    user_id = auth.uid() OR
    auth.uid() IN (
        SELECT user_id
        FROM goats
        WHERE id = goat_id
    )
);

CREATE POLICY "Users can add expenses"
ON public.expenses FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() IN (
        SELECT user_id
        FROM goats
        WHERE id = goat_id
    )
);

CREATE POLICY "Users can view their sales"
ON public.sales FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can manage their sales"
ON public.sales FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());
