-- Create sales table
CREATE TABLE IF NOT EXISTS public.sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES public.goats(id) ON DELETE CASCADE NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL CHECK (sale_price >= 0),
    sale_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    buyer_info TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Enable RLS
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

-- Create policies
DO $$ 
BEGIN
    -- Create view policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'sales' 
        AND policyname = 'Users can view their own sales'
    ) THEN
        CREATE POLICY "Users can view their own sales" ON public.sales
        FOR SELECT USING (auth.uid() = user_id);
    END IF;

    -- Create insert policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'sales' 
        AND policyname = 'Users can insert sales'
    ) THEN
        CREATE POLICY "Users can insert sales" ON public.sales
        FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;

    -- Create update policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'sales' 
        AND policyname = 'Users can update their own sales'
    ) THEN
        CREATE POLICY "Users can update their own sales" ON public.sales
        FOR UPDATE USING (auth.uid() = user_id);
    END IF;

    -- Create delete policy
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'sales' 
        AND policyname = 'Users can delete their own sales'
    ) THEN
        CREATE POLICY "Users can delete their own sales" ON public.sales
        FOR DELETE USING (auth.uid() = user_id);
    END IF;
END
$$;
