-- Update expense policies
BEGIN;

-- Drop existing expense policies
DROP POLICY IF EXISTS "Users can view expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can manage expenses for their goats" ON public.expenses;
DROP POLICY IF EXISTS "Users can insert their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete their own expenses" ON public.expenses;

-- Create new expense policies
CREATE POLICY "Users can view expenses for their goats"
ON public.expenses FOR SELECT
TO authenticated
USING (
    user_id = auth.uid() OR
    goat_id IN (SELECT id FROM public.goats WHERE user_id = auth.uid())
);

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
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete their own expenses"
ON public.expenses FOR DELETE
TO authenticated
USING (user_id = auth.uid());

COMMIT;
