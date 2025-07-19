-- Start transaction
BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS "public";

-- Clean up existing objects safely
DO $$ 
BEGIN
    -- Drop view first as it depends on tables
    DROP VIEW IF EXISTS "public"."v_goat_financials" CASCADE;
    
    -- Drop existing policies
    DROP POLICY IF EXISTS "Users can access own caretakers" ON "public"."caretakers";
    DROP POLICY IF EXISTS "Users can access own goats" ON "public"."goats";
    DROP POLICY IF EXISTS "Users can access expenses for their goats" ON "public"."expenses";
    DROP POLICY IF EXISTS "Users can access sales for their goats" ON "public"."sales";
    DROP POLICY IF EXISTS "Users can access weight logs for their goats" ON "public"."weight_logs";
    DROP POLICY IF EXISTS "Users can access notifications for their goats" ON "public"."notifications";
    
    -- Drop tables in reverse order of dependencies
    DROP TABLE IF EXISTS "public"."notifications" CASCADE;
    DROP TABLE IF EXISTS "public"."weight_logs" CASCADE;
    DROP TABLE IF EXISTS "public"."sales" CASCADE;
    DROP TABLE IF EXISTS "public"."expenses" CASCADE;
    DROP TABLE IF EXISTS "public"."goats" CASCADE;
    DROP TABLE IF EXISTS "public"."caretakers" CASCADE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error during cleanup: %', SQLERRM;
END $$;

-- Create all base tables first
CREATE TABLE IF NOT EXISTS "public"."caretakers" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "name" text NOT NULL,
    "phone" text,
    "location" text,
    "payment_terms" text,
    "user_id" uuid NOT NULL,
    CONSTRAINT "caretakers_pkey" PRIMARY KEY ("id")
);

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
    "caretaker_id" uuid REFERENCES public.caretakers(id) ON DELETE SET NULL,
    "price" numeric(10,2),
    CONSTRAINT "goats_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "goats_tag_number_key" UNIQUE ("tag_number")
);

CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "caretaker_id" uuid,
    "amount" numeric(10,2) NOT NULL,
    "description" text NOT NULL,
    "date" date NOT NULL,
    "type" text NOT NULL,
    CONSTRAINT "expenses_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "sale_date" date NOT NULL,
    "sale_price" numeric(10,2) NOT NULL,
    "buyer_name" text,
    "buyer_phone" text,
    "notes" text,
    CONSTRAINT "sales_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "public"."weight_logs" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "caretaker_id" uuid,
    "weight" numeric(5,2) NOT NULL,
    "date" date NOT NULL,
    "notes" text,
    CONSTRAINT "weight_logs_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "created_at" timestamp with time zone DEFAULT now(),
    "goat_id" uuid NOT NULL,
    "type" text NOT NULL,
    "message" text NOT NULL,
    "read" boolean DEFAULT false,
    "date" date NOT NULL,
    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- Add foreign key constraints
DO $$ 
BEGIN
    ALTER TABLE "public"."expenses"
        ADD CONSTRAINT "expenses_goat_id_fkey" 
        FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE,
        ADD CONSTRAINT "expenses_caretaker_id_fkey" 
        FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id") ON DELETE SET NULL;

    ALTER TABLE "public"."sales"
        ADD CONSTRAINT "sales_goat_id_fkey" 
        FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;

    ALTER TABLE "public"."weight_logs"
        ADD CONSTRAINT "weight_logs_goat_id_fkey" 
        FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE,
        ADD CONSTRAINT "weight_logs_caretaker_id_fkey" 
        FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id") ON DELETE SET NULL;

    ALTER TABLE "public"."notifications"
        ADD CONSTRAINT "notifications_goat_id_fkey" 
        FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error adding foreign keys: %', SQLERRM;
        RAISE;
END $$;

-- Enable Row Level Security
DO $$ 
BEGIN
    ALTER TABLE "public"."caretakers" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "public"."goats" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "public"."expenses" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "public"."weight_logs" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error enabling RLS: %', SQLERRM;
        RAISE;
END $$;

-- Create RLS Policies
DO $$ 
BEGIN
    -- Caretakers policies
    CREATE POLICY "Enable insert for authenticated users" ON "public"."caretakers"
        FOR INSERT
        TO authenticated
        WITH CHECK (auth.uid() = user_id);

    CREATE POLICY "Enable select for users based on user_id" ON "public"."caretakers"
        FOR SELECT
        TO authenticated
        USING (auth.uid() = user_id);

    CREATE POLICY "Enable update for users based on user_id" ON "public"."caretakers"
        FOR UPDATE
        TO authenticated
        USING (auth.uid() = user_id)
        WITH CHECK (auth.uid() = user_id);

    CREATE POLICY "Enable delete for users based on user_id" ON "public"."caretakers"
        FOR DELETE
        TO authenticated
        USING (auth.uid() = user_id);

    -- Goats policies
    CREATE POLICY "Users can access own goats" ON "public"."goats"
        FOR ALL
        USING (auth.uid() = user_id)
        WITH CHECK (auth.uid() = user_id);

    -- Expenses policies
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

    -- Sales policies
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

    -- Weight logs policies
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

    -- Notifications policies
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
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating RLS policies: %', SQLERRM;
        RAISE;
END $$;

-- Create financial view
CREATE OR REPLACE VIEW "public"."v_goat_financials" AS
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

COMMIT;
