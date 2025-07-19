-- Fix tables schema and add missing columns
BEGIN;

-- First fix expenses table
DO $$ 
BEGIN 
    -- Add user_id to expenses if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public'
        AND table_name = 'expenses' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.expenses 
        ADD COLUMN user_id UUID REFERENCES auth.users(id);

        -- Set user_id for existing expenses
        UPDATE public.expenses e
        SET user_id = g.user_id
        FROM public.goats g
        WHERE e.goat_id = g.id
        AND e.user_id IS NULL;

        ALTER TABLE public.expenses 
        ALTER COLUMN user_id SET NOT NULL;
    END IF;
END $$;

-- Then fix notifications table
DROP TABLE IF EXISTS public.notifications;
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    record_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Enable RLS on both tables
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create expense policies
DROP POLICY IF EXISTS "Users can view their expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can add expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete expenses" ON public.expenses;

CREATE POLICY "Users can view their expenses"
ON public.expenses
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can add expenses"
ON public.expenses
FOR INSERT
TO authenticated
WITH CHECK (
    goat_id IN (
        SELECT id FROM goats WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Users can update expenses"
ON public.expenses
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (
    goat_id IN (
        SELECT id FROM goats WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Users can delete expenses"
ON public.expenses
FOR DELETE
TO authenticated
USING (user_id = auth.uid());

-- Create notification policies
DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark notifications as read" ON public.notifications;
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

CREATE POLICY "Users can view their notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can mark notifications as read"
ON public.notifications
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "System can create notifications"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Grant permissions
GRANT ALL ON public.expenses TO postgres;
GRANT ALL ON public.notifications TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.expenses TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.notifications TO authenticated;
GRANT SELECT ON public.expenses TO anon;
GRANT SELECT ON public.notifications TO anon;

-- Create expense trigger to set user_id
CREATE OR REPLACE FUNCTION public.set_expense_user_id()
RETURNS TRIGGER AS $$
BEGIN
    NEW.user_id := auth.uid();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS set_expense_user_id ON public.expenses;
CREATE TRIGGER set_expense_user_id
    BEFORE INSERT ON public.expenses
    FOR EACH ROW
    EXECUTE FUNCTION public.set_expense_user_id();

-- Create indexes
CREATE INDEX IF NOT EXISTS expenses_user_id_idx ON public.expenses(user_id);
CREATE INDEX IF NOT EXISTS expenses_goat_id_idx ON public.expenses(goat_id);
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_created_at_idx ON public.notifications(created_at DESC);

COMMIT;
