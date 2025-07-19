
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    birth_date TIMESTAMP WITH TIME ZONE,
    price DECIMAL(10,2),
    photo_url TEXT,
    gender VARCHAR DEFAULT 'unknown',
    status VARCHAR DEFAULT 'active',
    caretaker_id UUID REFERENCES public.caretakers(id),
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id, tag_number)
);

CREATE TABLE IF NOT EXISTS public.caretakers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    phone VARCHAR,
    location VARCHAR,
    payment_terms VARCHAR,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    amount DECIMAL(10,2) NOT NULL,
    type VARCHAR NOT NULL,
    notes TEXT,
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    sale_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE IF NOT EXISTS public.weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    weight DECIMAL(5,2) NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE IF NOT EXISTS public.scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    scan_type VARCHAR NOT NULL,
    location VARCHAR,
    notes TEXT,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message TEXT NOT NULL,
    type VARCHAR NOT NULL,
    record_id UUID NOT NULL,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create view for financial summaries with correct column names
CREATE OR REPLACE VIEW public.v_goat_financials AS
WITH expense_totals AS (
    SELECT goat_id, COALESCE(SUM(amount), 0) as total_expense
    FROM public.expenses
    GROUP BY goat_id
)
SELECT 
    g.id as goat_id,
    g.tag_number as tag_number,
    g.name as goat_name,
    g.price,
    s.sale_price,
    COALESCE(e.total_expense, 0) as total_expense,
    g.status,
    g.created_at
FROM public.goats g
LEFT JOIN expense_totals e ON g.id = e.goat_id
LEFT JOIN public.sales s ON g.id = s.goat_id;

ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caretakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own goats"
ON public.goats FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own goats"
ON public.goats FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own goats"
ON public.goats FOR UPDATE
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can view their goats' caretakers"
ON public.caretakers FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can manage their goats' caretakers"
ON public.caretakers FOR ALL
TO authenticated
USING (user_id = auth.uid());
