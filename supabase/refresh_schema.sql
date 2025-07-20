-- Drop the view if it exists
DROP VIEW IF EXISTS caretakers_view;

-- Create a view to force schema cache refresh
CREATE OR REPLACE VIEW caretakers_view AS
SELECT 
    id,
    name,
    phone,
    location,
    payment_type,
    profit_share_pct,
    monthly_fee,
    notes,
    created_at,
    user_id
FROM caretakers;

-- Notify PostgREST to refresh its schema cache
NOTIFY pgrst, 'reload schema';
