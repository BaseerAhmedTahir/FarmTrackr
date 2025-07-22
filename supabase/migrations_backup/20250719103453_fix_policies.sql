-- Drop existing policies
DO $$ 
BEGIN
    -- Drop all policies on expenses table
    EXECUTE (
        SELECT string_agg(
            format('DROP POLICY IF EXISTS %I ON public.expenses', polname),
            '; '
        )
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'expenses'
    );
END $$;

-- Recreate policies
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

CREATE POLICY "Users can view their expenses"
ON public.expenses
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
    auth.uid() IN (
        SELECT user_id
        FROM goats
        WHERE id = goat_id
    )
);
