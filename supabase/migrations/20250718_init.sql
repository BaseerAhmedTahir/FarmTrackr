-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "moddatetime";

-- Drop and recreate expenses table
DROP TABLE IF EXISTS public.expenses CASCADE;

CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type VARCHAR NOT NULL,
    notes TEXT DEFAULT '',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID NOT NULL
);

-- Create index for better query performance
CREATE INDEX idx_expenses_goat_id ON public.expenses(goat_id);
CREATE INDEX idx_expenses_user_id ON public.expenses(user_id);"uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "moddatetime";

-- Create storage bucket for goat photos
INSERT INTO storage.buckets (id, name, public, avif_autodetection, file_size_limit, allowed_mime_types)
VALUES ('goat-photos', 'goat-photos', true, false, 52428800, '{"image/jpeg","image/png","image/webp"}')
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Create enum types
DO $$ BEGIN
    CREATE TYPE public.goat_status AS ENUM ('active', 'sold', 'deceased');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.goat_gender AS ENUM ('male', 'female', 'unknown');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Create caretakers table
CREATE TABLE IF NOT EXISTS public.caretakers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    phone VARCHAR,
    location VARCHAR,
    payment_terms VARCHAR,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create goats table
CREATE TABLE IF NOT EXISTS public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    birth_date TIMESTAMP WITH TIME ZONE,
    price DECIMAL(10,2) CHECK (price >= 0),
    photo_url TEXT,
    gender goat_gender DEFAULT 'unknown',
    status goat_status DEFAULT 'active',
    caretaker_id UUID REFERENCES public.caretakers(id) ON DELETE SET NULL,
    user_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(user_id, tag_number)
);

-- Other related tables
-- Drop and recreate expenses table to ensure clean schema
DROP TABLE IF EXISTS public.expenses CASCADE;

CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type VARCHAR NOT NULL,
    notes TEXT DEFAULT '',
    expense_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Create index for better query performance
CREATE INDEX idx_expenses_goat_id ON public.expenses(goat_id);
CREATE INDEX idx_expenses_expense_date ON public.expenses(expense_date);

CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    sale_price DECIMAL(10,2) NOT NULL,
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    weight DECIMAL(5,2) NOT NULL,
    date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id),
    scan_type VARCHAR NOT NULL,
    location VARCHAR,
    notes TEXT,
    scanned_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message TEXT NOT NULL,
    type VARCHAR NOT NULL,
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Materialized view for financial data
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

-- Enable RLS
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.caretakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- === POLICIES ===

-- Goats
DROP POLICY IF EXISTS "Users can view their own goats" ON public.goats;
DROP POLICY IF EXISTS "Users can insert their own goats" ON public.goats;
DROP POLICY IF EXISTS "Users can update their own goats" ON public.goats;

CREATE POLICY "Users can view their own goats"
ON public.goats FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own goats"
ON public.goats FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own goats"
ON public.goats FOR UPDATE TO authenticated
USING (user_id = auth.uid());

-- Caretakers
DROP POLICY IF EXISTS "Users can view their goats' caretakers" ON public.caretakers;
DROP POLICY IF EXISTS "Users can manage their goats' caretakers" ON public.caretakers;

CREATE POLICY "Users can view their goats' caretakers"
ON public.caretakers FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can manage their goats' caretakers"
ON public.caretakers FOR ALL TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Expenses
DROP POLICY IF EXISTS "Users can view expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can manage expenses for their goats" ON public.expenses;

CREATE POLICY "Users can view expenses for their goats"
ON public.expenses FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can insert expenses"
ON public.expenses FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their expenses"
ON public.expenses FOR UPDATE TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their expenses"
ON public.expenses FOR DELETE TO authenticated
USING (user_id = auth.uid());

-- Sales
DROP POLICY IF EXISTS "Users can view sales for their goats" ON public.sales;
DROP POLICY IF EXISTS "Users can manage sales for their goats" ON public.sales;

CREATE POLICY "Users can view sales for their goats"
ON public.sales FOR SELECT TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage sales for their goats"
ON public.sales FOR ALL TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

-- Weight logs
DROP POLICY IF EXISTS "Users can view weight logs for their goats" ON public.weight_logs;
DROP POLICY IF EXISTS "Users can manage weight logs for their goats" ON public.weight_logs;

CREATE POLICY "Users can view weight logs for their goats"
ON public.weight_logs FOR SELECT TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage weight logs for their goats"
ON public.weight_logs FOR ALL TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

-- Scans
DROP POLICY IF EXISTS "Users can view scans for their goats" ON public.scans;
DROP POLICY IF EXISTS "Users can manage scans for their goats" ON public.scans;

CREATE POLICY "Users can view scans for their goats"
ON public.scans FOR SELECT TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage scans for their goats"
ON public.scans FOR ALL TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

-- Notifications
DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can manage their notifications" ON public.notifications;

CREATE POLICY "Users can view their notifications"
ON public.notifications FOR SELECT TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage their notifications"
ON public.notifications FOR ALL TO authenticated
USING (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()))
WITH CHECK (goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid()));

-- === TRIGGERS ===

DROP TRIGGER IF EXISTS refresh_financials_on_expense ON public.expenses;
CREATE TRIGGER refresh_financials_on_expense
AFTER INSERT OR UPDATE OR DELETE ON public.expenses
FOR EACH STATEMENT EXECUTE FUNCTION refresh_goat_financials();

DROP TRIGGER IF EXISTS refresh_financials_on_sale ON public.sales;
CREATE TRIGGER refresh_financials_on_sale
AFTER INSERT OR UPDATE OR DELETE ON public.sales
FOR EACH STATEMENT EXECUTE FUNCTION refresh_goat_financials();

DROP TRIGGER IF EXISTS refresh_financials_on_goat ON public.goats;
CREATE TRIGGER refresh_financials_on_goat
AFTER INSERT OR UPDATE OR DELETE ON public.goats
FOR EACH STATEMENT EXECUTE FUNCTION refresh_goat_financials();
