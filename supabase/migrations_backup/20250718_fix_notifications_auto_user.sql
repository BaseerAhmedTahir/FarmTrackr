-- Fix notifications with auto user_id and expense notifications
BEGIN;

-- Drop and recreate notifications table with correct columns
DROP TABLE IF EXISTS public.notifications CASCADE;
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL DEFAULT auth.uid(),  -- Set default to current user
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    record_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    read BOOLEAN DEFAULT false NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark notifications as read" ON public.notifications;
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

-- Create notification policies
CREATE POLICY "Users can view their notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "Users can mark notifications as read"
ON public.notifications
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "System can create notifications"
ON public.notifications
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Function to handle expense notifications
CREATE OR REPLACE FUNCTION public.handle_expense_notification()
RETURNS TRIGGER AS $$
DECLARE
    goat_name TEXT;
    expense_type TEXT;
    goat_user_id UUID;
BEGIN
    -- Get the goat's name and owner
    SELECT name, user_id INTO goat_name, goat_user_id
    FROM public.goats
    WHERE id = NEW.goat_id;

    -- Create notification
    INSERT INTO public.notifications (
        title,
        message,
        type,
        record_id,
        metadata,
        user_id  -- Will use the DEFAULT auth.uid() if not specified
    ) VALUES (
        'New Expense Added',
        format('New %s expense of %s added for %s', NEW.type, NEW.amount::text, goat_name),
        'expense',
        NEW.id,
        jsonb_build_object(
            'expense_id', NEW.id,
            'goat_id', NEW.goat_id,
            'amount', NEW.amount,
            'type', NEW.type
        ),
        goat_user_id
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop and recreate the expense notification trigger
DROP TRIGGER IF EXISTS create_expense_notification ON public.expenses;
CREATE TRIGGER create_expense_notification
    AFTER INSERT ON public.expenses
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_expense_notification();

-- Grant permissions
GRANT ALL ON public.notifications TO postgres;
GRANT SELECT, INSERT, UPDATE ON public.notifications TO authenticated;
GRANT SELECT ON public.notifications TO anon;

-- Create indexes
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_read_idx ON public.notifications(read);
CREATE INDEX IF NOT EXISTS notifications_created_at_idx ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS notifications_type_idx ON public.notifications(type);

COMMIT;
