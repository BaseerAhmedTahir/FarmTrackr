-- Fix expenses table schema and policies
BEGIN;

-- Add user_id column to expenses if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'expenses' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.expenses 
        ADD COLUMN user_id UUID REFERENCES auth.users(id);

        -- Update existing expenses to set user_id based on goat ownership
        UPDATE public.expenses e
        SET user_id = g.user_id
        FROM public.goats g
        WHERE e.goat_id = g.id
        AND e.user_id IS NULL;

        -- Make user_id NOT NULL after updating existing data
        ALTER TABLE public.expenses 
        ALTER COLUMN user_id SET NOT NULL;
    END IF;
END $$;

-- Create trigger to automatically set user_id on insert
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

-- Drop and recreate policies with updated conditions
DROP POLICY IF EXISTS "Users can view their expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can add expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can update expenses" ON public.expenses;
DROP POLICY IF EXISTS "Users can delete expenses" ON public.expenses;

-- Create new policies using both user_id and goat ownership
CREATE POLICY "Users can view their expenses"
ON public.expenses
AS PERMISSIVE
FOR SELECT
TO authenticated
USING (
    user_id = auth.uid() OR
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
    user_id = auth.uid() AND
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
    user_id = auth.uid() AND
    auth.uid() IN (
        SELECT user_id 
        FROM goats 
        WHERE id = goat_id
    )
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS expenses_user_id_idx ON public.expenses(user_id);
CREATE INDEX IF NOT EXISTS expenses_goat_id_idx ON public.expenses(goat_id);

COMMIT;
