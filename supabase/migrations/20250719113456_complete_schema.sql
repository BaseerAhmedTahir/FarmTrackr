-- Create caretakers table first
CREATE TABLE IF NOT EXISTS public.caretakers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    profit_share DECIMAL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create goats table
CREATE TABLE IF NOT EXISTS public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number TEXT UNIQUE NOT NULL,
    caretaker_id UUID REFERENCES public.caretakers(id) ON DELETE SET NULL,
    purchase_price DECIMAL NOT NULL,
    sale_price DECIMAL DEFAULT 0,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'sold', 'deceased')),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create expenses table
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

-- Create the view
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

-- Add Row Level Security (RLS) policies
ALTER TABLE public.caretakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Caretaker policies
CREATE POLICY "Users can view all caretakers"
ON public.caretakers FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Users can manage caretakers"
ON public.caretakers FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- Goat policies
CREATE POLICY "Users can view their goats"
ON public.goats FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can manage their goats"
ON public.goats FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Expense policies
CREATE POLICY "Users can view their expenses"
ON public.expenses FOR SELECT
TO authenticated
USING (
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
