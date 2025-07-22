-- Create tables if they don't exist
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

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.goats TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sales TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.expenses TO authenticated;

GRANT SELECT, INSERT, UPDATE, DELETE ON public.goats TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.sales TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.expenses TO service_role;
