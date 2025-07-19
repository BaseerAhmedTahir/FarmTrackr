-- Add profit_share column to caretakers
ALTER TABLE public.caretakers 
ADD COLUMN IF NOT EXISTS profit_share DECIMAL(5,2) NOT NULL DEFAULT 50.0 
CHECK (profit_share >= 0 AND profit_share <= 100.0);

-- Update existing caretakers to have a default 50% profit share if not set
UPDATE public.caretakers 
SET profit_share = 50.0 
WHERE profit_share IS NULL;
