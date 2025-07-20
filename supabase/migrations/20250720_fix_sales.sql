-- Drop existing policies first
DROP POLICY IF EXISTS "Users can view their own sales" ON sales;
DROP POLICY IF EXISTS "Users can insert their own sales" ON sales;
DROP POLICY IF EXISTS "Users can update their own sales" ON sales;
DROP POLICY IF EXISTS "Users can delete their own sales" ON sales;

-- Add RLS policies for sales table
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- Policy for viewing sales - users can only see their own sales
CREATE POLICY "Users can view their own sales"
ON sales FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy for inserting sales - users can only insert their own sales
CREATE POLICY "Users can insert their own sales"
ON sales FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy for updating sales - users can only update their own sales
CREATE POLICY "Users can update their own sales"
ON sales FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy for deleting sales - users can only delete their own sales
CREATE POLICY "Users can delete their own sales"
ON sales FOR DELETE
TO authenticated
USING (auth.uid() = user_id);