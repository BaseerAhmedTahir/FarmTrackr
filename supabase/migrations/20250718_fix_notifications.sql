-- Fix notifications table schema
BEGIN;

-- First, let's see if we need to create the notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    record_id UUID, -- This was missing and causing the error
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Enable RLS on notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their notifications" ON public.notifications;
DROP POLICY IF EXISTS "Users can mark notifications as read" ON public.notifications;
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

-- Create policies for notifications
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

-- Create index for better performance
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_created_at_idx ON public.notifications(created_at DESC);

COMMIT;
