-- Add gender column to goats table
ALTER TABLE public.goats
ADD COLUMN gender VARCHAR DEFAULT 'unknown';

-- Enable Row Level Security
ALTER TABLE public.goats ENABLE ROW LEVEL SECURITY;

-- Create policies if they don't exist
DO $$ 
BEGIN
    -- Create view policy if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'goats' 
        AND policyname = 'Users can view their own goats'
    ) THEN
        CREATE POLICY "Users can view their own goats" ON public.goats
        FOR SELECT USING (auth.uid() = user_id);
    END IF;

    -- Create insert policy if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'goats' 
        AND policyname = 'Users can insert their own goats'
    ) THEN
        CREATE POLICY "Users can insert their own goats" ON public.goats
        FOR INSERT WITH CHECK (auth.uid() = user_id);
    END IF;

    -- Create update policy if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'goats' 
        AND policyname = 'Users can update their own goats'
    ) THEN
        CREATE POLICY "Users can update their own goats" ON public.goats
        FOR UPDATE USING (auth.uid() = user_id);
    END IF;

    -- Create delete policy if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'goats' 
        AND policyname = 'Users can delete their own goats'
    ) THEN
        CREATE POLICY "Users can delete their own goats" ON public.goats
        FOR DELETE USING (auth.uid() = user_id);
    END IF;
END
$$;
