-- Add missing tables for expenses, sales, weight logs, and notifications

-- Expenses table
CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "id" uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    "goat_id" uuid REFERENCES goats(id) ON DELETE CASCADE,
    "amount" numeric(12,2) NOT NULL,
    "type" text NOT NULL,
    "notes" text,
    "expense_date" timestamp with time zone DEFAULT now(),
    "created_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."expenses" OWNER TO "postgres";

-- Sales table
CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    "goat_id" uuid REFERENCES goats(id) ON DELETE CASCADE,
    "sale_price" numeric(12,2) NOT NULL,
    "sale_date" timestamp with time zone DEFAULT now(),
    "payment_mode" text,
    "created_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."sales" OWNER TO "postgres";

-- Weight logs table
CREATE TABLE IF NOT EXISTS "public"."weight_logs" (
    "id" uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    "goat_id" uuid REFERENCES goats(id) ON DELETE CASCADE,
    "weight_kg" numeric(6,2) NOT NULL,
    "recorded_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."weight_logs" OWNER TO "postgres";

-- Notifications table
CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    "message" text NOT NULL,
    "type" text NOT NULL,
    "record_id" uuid,
    "read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT now()
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

-- Add primary keys
ALTER TABLE ONLY "public"."expenses" ADD CONSTRAINT "expenses_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."sales" ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."weight_logs" ADD CONSTRAINT "weight_logs_pkey" PRIMARY KEY ("id");
ALTER TABLE ONLY "public"."notifications" ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");

-- Enable RLS on new tables
ALTER TABLE "public"."expenses" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."weight_logs" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

-- Add RLS policies for authenticated users
CREATE POLICY "Full access for authenticated" ON "public"."expenses"
    USING (auth.role() = 'authenticated'::text)
    WITH CHECK (auth.role() = 'authenticated'::text);

CREATE POLICY "Full access for authenticated" ON "public"."sales"
    USING (auth.role() = 'authenticated'::text)
    WITH CHECK (auth.role() = 'authenticated'::text);

CREATE POLICY "Full access for authenticated" ON "public"."weight_logs"
    USING (auth.role() = 'authenticated'::text)
    WITH CHECK (auth.role() = 'authenticated'::text);

CREATE POLICY "Full access for authenticated" ON "public"."notifications"
    USING (auth.role() = 'authenticated'::text)
    WITH CHECK (auth.role() = 'authenticated'::text);

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
CREATE OR REPLACE VIEW "public"."v_goat_financials" AS
SELECT
    g.id,
    g.tag_id,
    g.purchase_price,
    COALESCE(SUM(e.amount), 0::numeric) as total_expense,
    s.sale_price,
    (COALESCE(s.sale_price, 0::numeric) - g.purchase_price - COALESCE(SUM(e.amount), 0::numeric)) as net_profit
FROM goats g
LEFT JOIN expenses e ON e.goat_id = g.id
LEFT JOIN sales s ON s.goat_id = g.id
GROUP BY g.id, g.tag_id, g.purchase_price, s.sale_price;

-- Grant permissions on new tables
GRANT ALL ON TABLE "public"."expenses" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."sales" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."weight_logs" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."notifications" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."v_goat_financials" TO "anon", "authenticated", "service_role";
