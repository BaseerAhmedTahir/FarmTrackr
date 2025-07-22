-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create enum types
DO $$ BEGIN
    CREATE TYPE expense_type AS ENUM ('feed', 'medicine', 'transport', 'other');
    CREATE TYPE goat_status AS ENUM ('active', 'sold', 'dead');
    CREATE TYPE health_record_type AS ENUM ('vaccination', 'illness', 'injury', 'deworming', 'other');
    CREATE TYPE health_status AS ENUM ('healthy', 'under_treatment', 'recovered', 'deceased');
EXCEPTION 
    WHEN duplicate_object THEN null;
END $$;

-- Drop existing tables if they exist to ensure clean slate
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.expenses CASCADE;
DROP TABLE IF EXISTS public.sales CASCADE;
DROP TABLE IF EXISTS public.purchases CASCADE;
DROP TABLE IF EXISTS public.breeding_records CASCADE;
DROP TABLE IF EXISTS public.health_records CASCADE;
DROP TABLE IF EXISTS public.weight_logs CASCADE;
DROP TABLE IF EXISTS public.goats CASCADE;

-- Base tables
CREATE TABLE public.goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    breed TEXT,
    gender TEXT NOT NULL,
    birth_date DATE NOT NULL,
    color TEXT,
    markings TEXT,
    photo_url TEXT,
    qr_code TEXT UNIQUE,
    status goat_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL CHECK (weight_kg > 0),
    measured_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    record_type health_record_type NOT NULL,
    record_date DATE NOT NULL,
    diagnosis TEXT,
    treatment TEXT,
    medicine TEXT,
    dosage TEXT,
    next_due_date DATE,
    vet_name TEXT,
    vet_contact TEXT,
    status health_status NOT NULL DEFAULT 'healthy',
    notes TEXT,
    attachments TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.breeding_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dam_id UUID REFERENCES public.goats(id) NOT NULL,
    sire_id UUID REFERENCES public.goats(id),
    mating_date DATE,
    expected_birth_date DATE,
    actual_birth_date DATE,
    number_of_kids INT,
    kids_detail JSONB,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    CONSTRAINT different_parents CHECK (dam_id != sire_id)
);

CREATE TABLE public.purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL CHECK (purchase_price >= 0),
    vendor_name TEXT,
    vendor_contact TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    sale_date DATE NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL CHECK (sale_price >= 0),
    buyer_name TEXT,
    buyer_contact TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type expense_type NOT NULL,
    notes TEXT,
    expense_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    due_date DATE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Views for analytics
CREATE OR REPLACE VIEW public.goat_financials AS
WITH goat_expenses AS (
    SELECT 
        goat_id,
        SUM(amount) as total_expenses
    FROM public.expenses
    GROUP BY goat_id
),
goat_sales AS (
    SELECT 
        goat_id,
        sale_price,
        sale_date
    FROM public.sales
),
goat_purchases AS (
    SELECT 
        goat_id,
        purchase_price,
        purchase_date
    FROM public.purchases
)
SELECT 
    g.id as goat_id,
    g.tag_number,
    g.name,
    g.status,
    COALESCE(p.purchase_price, 0) as purchase_price,
    p.purchase_date,
    COALESCE(s.sale_price, 0) as sale_price,
    s.sale_date,
    COALESCE(e.total_expenses, 0) as total_expenses,
    COALESCE(s.sale_price, 0) - COALESCE(p.purchase_price, 0) - COALESCE(e.total_expenses, 0) as net_profit
FROM public.goats g
LEFT JOIN goat_expenses e ON g.id = e.goat_id
LEFT JOIN goat_sales s ON g.id = s.goat_id
LEFT JOIN goat_purchases p ON g.id = p.goat_id;

-- Function to generate QR code (placeholder - implement actual QR generation in application)
CREATE OR REPLACE FUNCTION public.generate_goat_qr_code(goat_id UUID)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN 'https://goattracker.app/goat/' || goat_id::TEXT;
END;
$$;

-- Trigger for QR code generation
CREATE OR REPLACE FUNCTION public.handle_new_goat()
RETURNS TRIGGER AS $$
BEGIN
    NEW.qr_code := public.generate_goat_qr_code(NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_new_goat
    BEFORE INSERT ON public.goats
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_goat();

-- Trigger for health notifications
CREATE OR REPLACE FUNCTION public.handle_new_health_record()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.next_due_date IS NOT NULL THEN
        INSERT INTO public.notifications (
            user_id,
            goat_id,
            title,
            message,
            type,
            due_date
        ) VALUES (
            NEW.user_id,
            NEW.goat_id,
            CASE NEW.record_type
                WHEN 'vaccination' THEN 'Vaccination Due'
                WHEN 'deworming' THEN 'Deworming Due'
                ELSE 'Health Check Due'
            END,
            'Health record follow-up required for goat ' || (SELECT tag_number FROM public.goats WHERE id = NEW.goat_id),
            NEW.record_type::TEXT,
            NEW.next_due_date
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_new_health_record
    AFTER INSERT ON public.health_records
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_health_record();

-- Row Level Security (RLS)
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own goats"
    ON public.goats FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goats"
    ON public.goats FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goats"
    ON public.goats FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goats"
    ON public.goats FOR DELETE
    USING (auth.uid() = user_id);

-- Similar policies for other tables
DO $$ 
DECLARE
    table_name text;
BEGIN
    FOR table_name IN 
        SELECT unnest(ARRAY['weight_logs', 'health_records', 'breeding_records', 
                           'purchases', 'sales', 'expenses', 'notifications'])
    LOOP
        EXECUTE format('
            CREATE POLICY "Users can view their own %1$s"
                ON public.%1$s FOR SELECT
                USING (auth.uid() = user_id);
                
            CREATE POLICY "Users can insert their own %1$s"
                ON public.%1$s FOR INSERT
                WITH CHECK (auth.uid() = user_id);
                
            CREATE POLICY "Users can update their own %1$s"
                ON public.%1$s FOR UPDATE
                USING (auth.uid() = user_id)
                WITH CHECK (auth.uid() = user_id);
                
            CREATE POLICY "Users can delete their own %1$s"
                ON public.%1$s FOR DELETE
                USING (auth.uid() = user_id);
        ', table_name);
    END LOOP;
END $$;

-- End of migration
