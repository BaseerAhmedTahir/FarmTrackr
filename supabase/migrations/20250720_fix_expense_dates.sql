-- Fix expense table date fields
BEGIN;

-- Rename fields to match expected names
ALTER TABLE expenses
    DROP COLUMN IF EXISTS date,
    DROP COLUMN IF EXISTS created_at;

ALTER TABLE expenses
    ADD COLUMN expense_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_expenses_expense_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at);

COMMIT;
