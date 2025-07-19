-- Set default values for notifications table
BEGIN;

-- Drop and recreate notifications table with default values
DROP TABLE IF EXISTS public.notifications CASCADE;
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL DEFAULT auth.uid(),
    title TEXT NOT NULL DEFAULT 'New Notification',  -- Add default
    message TEXT NOT NULL DEFAULT 'You have a new notification',  -- Add default
    type TEXT NOT NULL DEFAULT 'system',  -- Add default
    record_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    read BOOLEAN DEFAULT false NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Create or replace function to handle notification defaults
CREATE OR REPLACE FUNCTION public.handle_notification_defaults()
RETURNS TRIGGER AS $$
BEGIN
    -- Set defaults if values are NULL
    NEW.title := COALESCE(NEW.title, 'New Notification');
    NEW.message := COALESCE(NEW.message, 'You have a new notification');
    NEW.type := COALESCE(NEW.type, 'system');
    NEW.created_at := COALESCE(NEW.created_at, NOW());
    NEW.read := COALESCE(NEW.read, false);
    NEW.metadata := COALESCE(NEW.metadata, '{}'::jsonb);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for notification defaults
DROP TRIGGER IF EXISTS set_notification_defaults ON public.notifications;
CREATE TRIGGER set_notification_defaults
    BEFORE INSERT ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_notification_defaults();

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

    -- Create notification with explicit values for all required fields
    INSERT INTO public.notifications (
        user_id,
        title,
        message,
        type,
        record_id,
        metadata
    ) VALUES (
        goat_user_id,
        'New Expense Added',
        format('New %s expense of %s added for %s', NEW.type, NEW.amount::text, COALESCE(goat_name, 'Unknown Goat')),
        'expense',
        NEW.id,
        jsonb_build_object(
            'expense_id', NEW.id,
            'goat_id', NEW.goat_id,
            'amount', NEW.amount,
            'type', NEW.type
        )
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

-- Recreate policies
DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark notifications as read" ON public.notifications;
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

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

-- Test the notification system
DO $$ 
BEGIN 
    -- Test direct notification insert with minimal fields
    INSERT INTO public.notifications DEFAULT VALUES;
    
    -- Test direct notification insert with just title
    INSERT INTO public.notifications (title) VALUES ('Test Notification');
END $$;
