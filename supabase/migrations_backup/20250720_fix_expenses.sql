-- Update expenses table to handle dates properly
BEGIN;

-- First rename created_at to expense_date to avoid confusion
ALTER TABLE expenses 
    RENAME COLUMN created_at TO expense_date;

-- Add a new created_at column for tracking record creation
ALTER TABLE expenses 
    ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();

-- Update indexes
DROP INDEX IF EXISTS idx_expenses_date;
CREATE INDEX idx_expenses_date ON expenses(expense_date);

COMMIT;
