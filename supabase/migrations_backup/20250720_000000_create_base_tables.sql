-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create enum types
CREATE TYPE expense_type AS ENUM ('feed', 'medicine', 'transport', 'other');
CREATE TYPE goat_status AS ENUM ('active', 'sold', 'dead');
CREATE TYPE health_record_type AS ENUM ('vaccination', 'illness', 'injury', 'deworming', 'other');
CREATE TYPE health_status AS ENUM ('healthy', 'under_treatment', 'recovered', 'deceased');

-- Base tables
CREATE TABLE IF NOT EXISTS public.goats (
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

CREATE TABLE IF NOT EXISTS public.weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL CHECK (weight_kg > 0),
    measured_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.health_records (
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

CREATE TABLE IF NOT EXISTS public.breeding_records (
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

CREATE TABLE IF NOT EXISTS public.purchases (
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

CREATE TABLE IF NOT EXISTS public.sales (
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

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    type expense_type NOT NULL,
    notes TEXT,
    expense_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.notifications (
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

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_goats_user ON public.goats(user_id);
CREATE INDEX IF NOT EXISTS idx_goats_tag ON public.goats(tag_number);
CREATE INDEX IF NOT EXISTS idx_goats_status ON public.goats(status);

CREATE INDEX IF NOT EXISTS idx_weight_logs_goat ON public.weight_logs(goat_id);
CREATE INDEX IF NOT EXISTS idx_weight_logs_user ON public.weight_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_weight_logs_date ON public.weight_logs(measured_at);

CREATE INDEX IF NOT EXISTS idx_health_records_goat ON public.health_records(goat_id);
CREATE INDEX IF NOT EXISTS idx_health_records_user ON public.health_records(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_type ON public.health_records(record_type);
CREATE INDEX IF NOT EXISTS idx_health_records_date ON public.health_records(record_date);
CREATE INDEX IF NOT EXISTS idx_health_records_next_due ON public.health_records(next_due_date);

CREATE INDEX IF NOT EXISTS idx_breeding_records_dam ON public.breeding_records(dam_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_sire ON public.breeding_records(sire_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_user ON public.breeding_records(user_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_date ON public.breeding_records(mating_date);

CREATE INDEX IF NOT EXISTS idx_purchases_goat ON public.purchases(goat_id);
CREATE INDEX IF NOT EXISTS idx_purchases_user ON public.purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_date ON public.purchases(purchase_date);

CREATE INDEX IF NOT EXISTS idx_sales_goat ON public.sales(goat_id);
CREATE INDEX IF NOT EXISTS idx_sales_user ON public.sales(user_id);
CREATE INDEX IF NOT EXISTS idx_sales_date ON public.sales(sale_date);

CREATE INDEX IF NOT EXISTS idx_expenses_goat ON public.expenses(goat_id);
CREATE INDEX IF NOT EXISTS idx_expenses_user ON public.expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_type ON public.expenses(type);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON public.expenses(expense_date);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_goat ON public.notifications(goat_id);
CREATE INDEX IF NOT EXISTS idx_notifications_date ON public.notifications(due_date);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);

-- Triggers for notifications
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

-- Row Level Security (RLS) Policies
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

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
CREATE POLICY "Users can view their own weight logs"
  ON public.weight_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own weight logs"
  ON public.weight_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own weight logs"
  ON public.weight_logs FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own weight logs"
  ON public.weight_logs FOR DELETE
  USING (auth.uid() = user_id);

-- Add similar policies for other tables

-- Triggers
CREATE TRIGGER on_new_health_record
  AFTER INSERT ON public.health_records
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_health_record();
