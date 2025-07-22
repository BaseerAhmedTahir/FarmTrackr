-- Start transaction
BEGIN;

-- Create payment_type enum if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type') THEN
        CREATE TYPE payment_type AS ENUM ('fixed', 'share');
    END IF;
END$$;

-- Add new columns with temporary constraint disabled
ALTER TABLE caretakers
ADD COLUMN IF NOT EXISTS monthly_fee DECIMAL,
ADD COLUMN IF NOT EXISTS profit_share_pct DECIMAL,
ADD COLUMN IF NOT EXISTS payment_type text,
ADD COLUMN IF NOT EXISTS notes text;

-- Set default values for existing records
UPDATE caretakers 
SET payment_type = 'fixed',
    monthly_fee = 0
WHERE payment_type IS NULL;

-- Convert payment_type to enum
ALTER TABLE caretakers
ALTER COLUMN payment_type TYPE payment_type USING payment_type::payment_type;

-- Make payment_type NOT NULL
ALTER TABLE caretakers
ALTER COLUMN payment_type SET NOT NULL;

-- Drop existing constraint if it exists
DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE table_name = 'caretakers'
        AND constraint_name = 'valid_payment'
    ) THEN
        ALTER TABLE caretakers DROP CONSTRAINT valid_payment;
    END IF;
END $$;

-- Add new constraint
ALTER TABLE caretakers
ADD CONSTRAINT valid_payment CHECK (
    CASE payment_type::text
        WHEN 'share' THEN profit_share_pct IS NOT NULL
        WHEN 'fixed' THEN monthly_fee IS NOT NULL
    END
);

-- Commit transaction
COMMIT;

-- Refresh the schema cache
NOTIFY pgrst, 'reload schema';
