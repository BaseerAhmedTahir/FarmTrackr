-- Clean up existing objects and policies
DROP VIEW IF EXISTS "public"."v_goat_financials";
DROP TABLE IF EXISTS "public"."notifications" CASCADE;
DROP TABLE IF EXISTS "public"."weight_logs" CASCADE;
DROP TABLE IF EXISTS "public"."sales" CASCADE;
DROP TABLE IF EXISTS "public"."expenses" CASCADE;
DROP TABLE IF EXISTS "public"."goats" CASCADE;
DROP TABLE IF EXISTS "public"."caretakers" CASCADE;

-- Drop existing policies
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."caretakers";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."goats";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."expenses";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."sales";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."weight_logs";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."notifications";
DROP POLICY IF EXISTS "caretaker_expense_policy" ON "public"."expenses";
DROP POLICY IF EXISTS "caretaker_weight_policy" ON "public"."weight_logs";

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- First create base tables
CREATE TABLE IF NOT EXISTS "public"."caretakers" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "name" text NOT NULL,
    "phone" text,
    "user_id" uuid NOT NULL,
    CONSTRAINT "caretakers_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "public"."caretakers" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."goats" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "name" text NOT NULL,
    "tag_number" text,
    "birth_date" date,
    "gender" text NOT NULL,
    "breed" text,
    "notes" text,
    "status" text DEFAULT 'active'::text,
    "photo_url" text,
    "user_id" uuid NOT NULL,
    CONSTRAINT "goats_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "public"."goats" OWNER TO "postgres";

-- Drop dependent foreign key constraints first
ALTER TABLE IF EXISTS "public"."expenses" DROP CONSTRAINT IF EXISTS "expenses_goat_id_fkey";
ALTER TABLE IF EXISTS "public"."sales" DROP CONSTRAINT IF EXISTS "sales_goat_id_fkey";
ALTER TABLE IF EXISTS "public"."weight_logs" DROP CONSTRAINT IF EXISTS "weight_logs_goat_id_fkey";

-- Drop existing constraints if they exist
ALTER TABLE IF EXISTS "public"."goats" DROP CONSTRAINT IF EXISTS "goats_caretaker_id_fkey";
ALTER TABLE IF EXISTS "public"."goats" DROP CONSTRAINT IF EXISTS "goats_tag_id_key";
ALTER TABLE IF EXISTS "public"."goats" DROP CONSTRAINT IF EXISTS "goats_pkey";
ALTER TABLE IF EXISTS "public"."caretakers" DROP CONSTRAINT IF EXISTS "caretakers_pkey";

-- Add primary keys and constraints
ALTER TABLE ONLY "public"."caretakers"
    ADD CONSTRAINT "caretakers_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_tag_id_key" UNIQUE ("tag_id");

ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_caretaker_id_fkey" FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id");

-- Recreate foreign key constraints for dependent tables
ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."weight_logs"
    ADD CONSTRAINT "weight_logs_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;

-- Create tables with foreign key dependencies
CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "caretaker_id" uuid,
    "amount" numeric(10,2) NOT NULL,
    "description" text NOT NULL,
    "date" date NOT NULL,
    "category" text NOT NULL,
    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "expenses_caretaker_id_fkey" FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id") ON DELETE SET NULL,
    CONSTRAINT "expenses_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."expenses" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "sale_date" date NOT NULL,
    "sale_price" numeric(10,2) NOT NULL,
    "buyer_name" text,
    "buyer_phone" text,
    "notes" text,
    CONSTRAINT "sales_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "sales_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."sales" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."weight_logs" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "caretaker_id" uuid,
    "weight" numeric(5,2) NOT NULL,
    "date" date NOT NULL,
    "notes" text,
    CONSTRAINT "weight_logs_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "weight_logs_caretaker_id_fkey" FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id") ON DELETE SET NULL,
    CONSTRAINT "weight_logs_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."weight_logs" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "type" text NOT NULL,
    "message" text NOT NULL,
    "read" boolean DEFAULT false,
    "date" date NOT NULL,
    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "notifications_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

-- Drop existing constraints if they exist
ALTER TABLE IF EXISTS "public"."expenses" DROP CONSTRAINT IF EXISTS "expenses_pkey";
ALTER TABLE IF EXISTS "public"."sales" DROP CONSTRAINT IF EXISTS "sales_pkey";
ALTER TABLE IF EXISTS "public"."weight_logs" DROP CONSTRAINT IF EXISTS "weight_logs_pkey";
ALTER TABLE IF EXISTS "public"."notifications" DROP CONSTRAINT IF EXISTS "notifications_pkey";

-- Add primary keys for new tables
ALTER TABLE ONLY "public"."expenses" ADD CONSTRAINT "expenses_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."sales" ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."weight_logs" ADD CONSTRAINT "weight_logs_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."notifications" ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

-- Enable RLS on all tables
ALTER TABLE "public"."caretakers" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."goats" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."expenses" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."weight_logs" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."caretakers";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."goats";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."expenses";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."sales";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."weight_logs";
DROP POLICY IF EXISTS "Full access for authenticated" ON "public"."notifications";
DROP POLICY IF EXISTS "caretaker_expense_policy" ON "public"."expenses";
DROP POLICY IF EXISTS "caretaker_weight_policy" ON "public"."weight_logs";

-- Add RLS policies
-- Create policies for user-specific access
CREATE POLICY "Users can access own caretakers" ON "public"."caretakers"
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can access own goats" ON "public"."goats"
    FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can access expenses for their goats" ON "public"."expenses"
    FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = expenses.goat_id
        AND g.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = expenses.goat_id
        AND g.user_id = auth.uid()
    ));

CREATE POLICY "Users can access sales for their goats" ON "public"."sales"
    FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = sales.goat_id
        AND g.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = sales.goat_id
        AND g.user_id = auth.uid()
    ));

CREATE POLICY "Users can access weight logs for their goats" ON "public"."weight_logs"
    FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = weight_logs.goat_id
        AND g.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = weight_logs.goat_id
        AND g.user_id = auth.uid()
    ));

CREATE POLICY "Users can access notifications for their goats" ON "public"."notifications"
    FOR ALL
    USING (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = notifications.goat_id
        AND g.user_id = auth.uid()
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.goats g
        WHERE g.id = notifications.goat_id
        AND g.user_id = auth.uid()
    ));

-- Add caretaker-specific policies
CREATE POLICY "caretaker_expense_policy" ON "public"."expenses"
    FOR ALL USING (
        (auth.jwt() ->> 'role'::text) = 'caretaker'::text
        AND EXISTS (
            SELECT 1 FROM goats g
            WHERE g.id = goat_id AND g.caretaker_id = auth.uid()
        )
    );

CREATE POLICY "caretaker_weight_policy" ON "public"."weight_logs"
    FOR ALL USING (
        (auth.jwt() ->> 'role'::text) = 'caretaker'::text
        AND EXISTS (
            SELECT 1 FROM goats g
            WHERE g.id = goat_id AND g.caretaker_id = auth.uid()
        )
    );

-- Create financial view
DROP VIEW IF EXISTS "public"."v_goat_financials";
CREATE VIEW "public"."v_goat_financials" AS
SELECT
    g.id as goat_id,
    g.name,
    g.tag_number,
    g.status,
    COALESCE(SUM(e.amount), 0::numeric) as total_expenses,
    COALESCE((
        SELECT sale_price 
        FROM sales s 
        WHERE s.goat_id = g.id
        ORDER BY sale_date DESC 
        LIMIT 1
    ), 0::numeric) as sale_price,
    (COALESCE((
        SELECT sale_price 
        FROM sales s 
        WHERE s.goat_id = g.id
        ORDER BY sale_date DESC 
        LIMIT 1
    ), 0::numeric) - COALESCE(SUM(e.amount), 0::numeric)) as net_profit
FROM goats g
LEFT JOIN expenses e ON e.goat_id = g.id
WHERE g.user_id = auth.uid()
GROUP BY g.id, g.name, g.tag_number, g.status;

-- Grant permissions
GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON TABLE "public"."caretakers" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."goats" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."expenses" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."sales" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."weight_logs" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."notifications" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."v_goat_financials" TO "anon", "authenticated", "service_role";

-- Create storage bucket for goat photos if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('goat-photos', 'goat-photos', false)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS for storage
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create storage policies
CREATE POLICY "Users can upload goat photos" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can access own goat photos" ON storage.objects
    FOR SELECT
    TO authenticated
    USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can update own goat photos" ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text)
    WITH CHECK (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can delete own goat photos" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (bucket_id = 'goat-photos' AND (storage.foldername(name))[1] = auth.uid()::text);CREATE POLICY "Goat photos are publicly accessible" ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'goat-photos');

CREATE POLICY "Users can update their own goat photos" ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'goat-photos' AND owner = auth.uid())
WITH CHECK (bucket_id = 'goat-photos' AND owner = auth.uid());

CREATE POLICY "Users can delete their own goat photos" ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'goat-photos' AND owner = auth.uid());
