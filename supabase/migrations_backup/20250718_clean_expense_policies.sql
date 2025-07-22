-- Clean up and recreate expense policies
BEGIN;

-- First, drop all existing policies
DROP POLICY IF EXISTS "Users can view expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can view their expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can insert expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can insert their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete their own expenses" ON public.expenses;

-- Make sure RLS is enabled
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Create new, clean policies
CREATE POLICY "Users can view their expenses"
ON public.expenses
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = expenses.goat_id
    )
);

CREATE POLICY "Users can add expenses"
ON public.expenses
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK (
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = goat_id
    )
);

CREATE POLICY "Users can update expenses"
ON public.expenses
AS PERMISSIVE
FOR UPDATE
TO authenticated
USING (
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = goat_id
    )
)
WITH CHECK (
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = goat_id
    )
);

CREATE POLICY "Users can delete expenses"
ON public.expenses
AS PERMISSIVE
FOR DELETE
TO authenticated
USING (
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = goat_id
    )
);

-- Grant appropriate permissions
GRANT ALL ON public.expenses TO postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.expenses TO authenticated;
GRANT SELECT ON public.expenses TO anon;

COMMIT;
