-- Fix expenses table and policies
BEGIN;

-- Add user_id column to expenses if it doesn't exist
ALTER TABLE public.expenses 
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id);

-- Update existing expenses to set user_id based on goat ownership
UPDATE public.expenses e
SET user_id = g.user_id
FROM public.goats g
WHERE e.goat_id = g.id
AND e.user_id IS NULL;

-- Make user_id NOT NULL after updating existing data
ALTER TABLE public.expenses 
ALTER COLUMN user_id SET NOT NULL;

-- Update the insert trigger to automatically set user_id
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

-- Drop and recreate policies
DROP POLICY IF EXISTS "Users can view expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can manage expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can insert their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete their own expenses" ON public.expenses;

-- Create new expense policies
CREATE POLICY "Users can view expenses for their goats"
ON public.expenses FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own expenses"
ON public.expenses FOR INSERT
TO authenticated
WITH CHECK (
    user_id = auth.uid() AND
    goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid())
);

CREATE POLICY "Users can update their own expenses"
ON public.expenses FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (
    user_id = auth.uid() AND
    goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid())
);

CREATE POLICY "Users can delete their own expenses"
ON public.expenses FOR DELETE
TO authenticated
USING (user_id = auth.uid());

COMMIT;
