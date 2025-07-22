-- Start transaction
BEGIN;

-- Drop view if it exists
DROP VIEW IF EXISTS caretakers_view;

-- Create or replace the view
CREATE OR REPLACE VIEW caretakers_view AS
SELECT 
    caretakers.id,
    caretakers.name,
    caretakers.phone,
    caretakers.location,
    caretakers.payment_type::text as payment_type,
    caretakers.profit_share_pct,
    caretakers.monthly_fee,
    caretakers.created_at,
    caretakers.user_id,
    auth.users.email as user_email,
    COALESCE(caretakers.notes, '') as notes
FROM 
    caretakers
    LEFT JOIN auth.users ON caretakers.user_id = auth.users.id;

-- Grant access to the authenticated role
GRANT SELECT ON caretakers_view TO authenticated;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';

-- Commit transaction
COMMIT;
