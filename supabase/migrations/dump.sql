

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."expense_type" AS ENUM (
    'feed',
    'medicine',
    'transport',
    'other'
);


ALTER TYPE "public"."expense_type" OWNER TO "postgres";


CREATE TYPE "public"."payment_type" AS ENUM (
    'fixed',
    'share'
);


ALTER TYPE "public"."payment_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_financial_summary"("user_id_param" "uuid") RETURNS TABLE("count" bigint, "invested" numeric, "sales" numeric, "profit" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    WITH user_goats AS (
        SELECT 
            g.id,
            g.price,
            g.status,
            COALESCE(e.total_expense, 0) as total_expense,
            s.sale_price
        FROM public.goats g
        LEFT JOIN (
            SELECT goat_id, SUM(amount) as total_expense
            FROM public.expenses
            GROUP BY goat_id
        ) e ON g.id = e.goat_id
        LEFT JOIN public.sales s ON g.id = s.goat_id
        WHERE g.user_id = user_id_param
    )
    SELECT 
        COUNT(*)::bigint,
        COALESCE(SUM(price), 0)::decimal,
        COALESCE(SUM(CASE WHEN status = 'sold' THEN sale_price ELSE 0 END), 0)::decimal,
        COALESCE(SUM(CASE 
            WHEN status = 'sold' 
            THEN sale_price - (price + total_expense)
            ELSE 0
        END), 0)::decimal
    FROM user_goats;
END;
$$;


ALTER FUNCTION "public"."get_financial_summary"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_financial_summary_v2"("user_id_param" "uuid") RETURNS TABLE("count" bigint, "invested" numeric, "sales" numeric, "profit" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_count bigint;
    v_invested numeric;
    v_sales numeric;
    v_profit numeric;
BEGIN
    -- Get basic counts first
    SELECT 
        COUNT(*),
        COALESCE(SUM(price), 0)
    INTO 
        v_count,
        v_invested
    FROM public.goats
    WHERE user_id = user_id_param;

    -- Get sales total
    SELECT COALESCE(SUM(sale_price), 0)
    INTO v_sales
    FROM public.sales s
    JOIN public.goats g ON s.goat_id = g.id
    WHERE g.user_id = user_id_param;

    -- Calculate profit
    SELECT COALESCE(SUM(s.sale_price - g.price - COALESCE(e.amount, 0)), 0)
    INTO v_profit
    FROM public.goats g
    LEFT JOIN public.sales s ON g.id = s.goat_id
    LEFT JOIN public.expenses e ON g.id = e.goat_id
    WHERE g.user_id = user_id_param
    AND g.status = 'sold';

    -- Return results
    RETURN QUERY 
    SELECT v_count, v_invested, v_sales, v_profit;
END;
$$;


ALTER FUNCTION "public"."get_financial_summary_v2"("user_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_uuid"("text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $_$
BEGIN
    RETURN $1 ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$_$;


ALTER FUNCTION "public"."is_uuid"("text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_uuid"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF NEW.id IS NULL OR NOT is_uuid(NEW.id::text) THEN
        NEW.id := uuid_generate_v4();
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."validate_uuid"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."caretakers" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying NOT NULL,
    "phone" character varying,
    "location" character varying,
    "payment_terms" character varying,
    "profit_share" numeric DEFAULT 0,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "monthly_fee" numeric,
    "profit_share_pct" numeric,
    "payment_type" "public"."payment_type" NOT NULL,
    "notes" "text",
    CONSTRAINT "valid_payment" CHECK (
CASE ("payment_type")::"text"
    WHEN 'share'::"text" THEN ("profit_share_pct" IS NOT NULL)
    WHEN 'fixed'::"text" THEN ("monthly_fee" IS NOT NULL)
    ELSE NULL::boolean
END)
);


ALTER TABLE "public"."caretakers" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."expenses" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "goat_id" "uuid",
    "amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "type" character varying NOT NULL,
    "notes" "text" DEFAULT ''::"text",
    "expense_date" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "expenses_amount_check" CHECK (("amount" >= (0)::numeric))
);


ALTER TABLE "public"."expenses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."goats" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "tag_number" character varying NOT NULL,
    "name" character varying NOT NULL,
    "birth_date" timestamp with time zone,
    "price" numeric(10,2) DEFAULT 0 NOT NULL,
    "photo_url" "text",
    "status" character varying DEFAULT 'active'::character varying,
    "caretaker_id" "uuid",
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "gender" character varying DEFAULT 'unknown'::character varying,
    "breed" "text",
    CONSTRAINT "goats_price_check" CHECK (("price" >= (0)::numeric))
);


ALTER TABLE "public"."goats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."sales" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "goat_id" "uuid",
    "user_id" "uuid",
    "sale_price" numeric NOT NULL,
    "sale_date" timestamp with time zone DEFAULT "now"() NOT NULL,
    "buyer_name" "text",
    "buyer_contact" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sales" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."caretaker_summary" AS
 SELECT "c"."id",
    "c"."name",
    "c"."phone" AS "contact",
    "count"(DISTINCT "g"."id") AS "total_goats",
    COALESCE("sum"("g"."price"), (0)::numeric) AS "total_investment",
    COALESCE("sum"(
        CASE
            WHEN ("s"."id" IS NOT NULL) THEN "s"."sale_price"
            ELSE (0)::numeric
        END), (0)::numeric) AS "total_sales",
    COALESCE("sum"(
        CASE
            WHEN ("s"."id" IS NOT NULL) THEN ("s"."sale_price" - "g"."price")
            ELSE (0)::numeric
        END), (0)::numeric) AS "gross_profit",
    COALESCE("sum"("e"."total_expenses"), (0)::numeric) AS "total_expenses",
    (COALESCE("sum"(
        CASE
            WHEN ("s"."id" IS NOT NULL) THEN ("s"."sale_price" - "g"."price")
            ELSE (0)::numeric
        END), (0)::numeric) - COALESCE("sum"("e"."total_expenses"), (0)::numeric)) AS "net_profit"
   FROM ((("public"."caretakers" "c"
     LEFT JOIN "public"."goats" "g" ON (("c"."id" = "g"."caretaker_id")))
     LEFT JOIN "public"."sales" "s" ON (("g"."id" = "s"."goat_id")))
     LEFT JOIN ( SELECT "expenses"."goat_id",
            "sum"("expenses"."amount") AS "total_expenses"
           FROM "public"."expenses"
          GROUP BY "expenses"."goat_id") "e" ON (("g"."id" = "e"."goat_id")))
  GROUP BY "c"."id", "c"."name", "c"."phone";


ALTER VIEW "public"."caretaker_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."caretakers_view" AS
 SELECT "caretakers"."id",
    "caretakers"."name",
    "caretakers"."phone",
    "caretakers"."location",
    ("caretakers"."payment_type")::"text" AS "payment_type",
    "caretakers"."profit_share_pct",
    "caretakers"."monthly_fee",
    "caretakers"."created_at",
    "caretakers"."user_id",
    "users"."email" AS "user_email",
    COALESCE("caretakers"."notes", ''::"text") AS "notes"
   FROM ("public"."caretakers"
     LEFT JOIN "auth"."users" ON (("caretakers"."user_id" = "users"."id")));


ALTER VIEW "public"."caretakers_view" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."expense_summary" AS
 SELECT "e"."id",
    "e"."type",
    "e"."amount",
    "e"."expense_date",
    "e"."created_at",
    "e"."notes",
    "g"."name" AS "goat_name",
    "g"."tag_number" AS "goat_tag",
    "c"."name" AS "caretaker_name"
   FROM (("public"."expenses" "e"
     LEFT JOIN "public"."goats" "g" ON (("e"."goat_id" = "g"."id")))
     LEFT JOIN "public"."caretakers" "c" ON (("g"."caretaker_id" = "c"."id")));


ALTER VIEW "public"."expense_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."goat_expenses" AS
 SELECT "g"."id",
    "g"."name",
    "g"."tag_number",
    COALESCE("sum"("e"."amount"), (0)::numeric) AS "total_expense",
    "count"("e"."id") AS "expense_count"
   FROM ("public"."goats" "g"
     LEFT JOIN "public"."expenses" "e" ON (("g"."id" = "e"."goat_id")))
  GROUP BY "g"."id", "g"."name", "g"."tag_number";


ALTER VIEW "public"."goat_expenses" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "message" "text" NOT NULL,
    "type" character varying NOT NULL,
    "record_id" "uuid" NOT NULL,
    "read" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()),
    "user_id" "uuid" NOT NULL
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."sales_summary" AS
 SELECT "s"."id",
    "s"."sale_date",
    "s"."created_at",
    "s"."sale_price",
    "s"."buyer_name",
    "s"."buyer_contact",
    "s"."notes",
    "g"."name" AS "goat_name",
    "g"."tag_number" AS "goat_tag",
    "g"."price" AS "goat_purchase_price",
    ("s"."sale_price" - COALESCE("g"."price", (0)::numeric)) AS "profit",
    "c"."name" AS "caretaker_name",
    "u"."email" AS "user_email"
   FROM ((("public"."sales" "s"
     LEFT JOIN "public"."goats" "g" ON (("s"."goat_id" = "g"."id")))
     LEFT JOIN "public"."caretakers" "c" ON (("g"."caretaker_id" = "c"."id")))
     LEFT JOIN "auth"."users" "u" ON (("s"."user_id" = "u"."id")));


ALTER VIEW "public"."sales_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_caretaker_summary" AS
 WITH "goat_data" AS (
         SELECT "c_1"."id" AS "caretaker_id",
            "count"(DISTINCT "g"."id") AS "total_goats",
            COALESCE("sum"("g"."price"), (0)::numeric) AS "total_investment",
            COALESCE("sum"(
                CASE
                    WHEN (("g"."status")::"text" = 'sold'::"text") THEN "g"."price"
                    ELSE (0)::numeric
                END), (0)::numeric) AS "sold_investment"
           FROM ("public"."caretakers" "c_1"
             LEFT JOIN "public"."goats" "g" ON (("g"."caretaker_id" = "c_1"."id")))
          GROUP BY "c_1"."id"
        ), "expense_totals" AS (
         SELECT "c_1"."id" AS "caretaker_id",
            COALESCE("sum"("e"."amount"), (0)::numeric) AS "total_expenses"
           FROM (("public"."caretakers" "c_1"
             LEFT JOIN "public"."goats" "g" ON (("g"."caretaker_id" = "c_1"."id")))
             LEFT JOIN "public"."expenses" "e" ON (("e"."goat_id" = "g"."id")))
          GROUP BY "c_1"."id"
        )
 SELECT "c"."id",
    "c"."name",
    "c"."phone",
    "c"."location",
    COALESCE("c"."profit_share", (0)::numeric) AS "profit_share",
    "c"."created_at",
    COALESCE("gd"."total_goats", (0)::bigint) AS "total_goats",
    COALESCE("gd"."total_investment", (0)::numeric) AS "total_investment",
    COALESCE("gd"."sold_investment", (0)::numeric) AS "sold_investment",
    COALESCE("et"."total_expenses", (0)::numeric) AS "total_expenses",
    "round"(((COALESCE("gd"."sold_investment", (0)::numeric) * COALESCE("c"."profit_share", (0)::numeric)) / (100)::numeric), 2) AS "profit_share_amount"
   FROM (("public"."caretakers" "c"
     LEFT JOIN "goat_data" "gd" ON (("gd"."caretaker_id" = "c"."id")))
     LEFT JOIN "expense_totals" "et" ON (("et"."caretaker_id" = "c"."id")));


ALTER VIEW "public"."v_caretaker_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_goat_financials" AS
 SELECT "g"."id",
    "g"."name",
    "g"."tag_number",
    "g"."price" AS "purchase_price",
    COALESCE("s"."sale_price", (0)::numeric) AS "sale_price",
    COALESCE(("s"."sale_price" - "g"."price"), (0)::numeric) AS "profit",
    COALESCE("e"."total_expenses", (0)::numeric) AS "total_expenses",
    COALESCE((("s"."sale_price" - "g"."price") - "e"."total_expenses"), ((- "g"."price") - COALESCE("e"."total_expenses", (0)::numeric))) AS "net_profit"
   FROM (("public"."goats" "g"
     LEFT JOIN "public"."sales" "s" ON (("g"."id" = "s"."goat_id")))
     LEFT JOIN ( SELECT "expenses"."goat_id",
            "sum"("expenses"."amount") AS "total_expenses"
           FROM "public"."expenses"
          GROUP BY "expenses"."goat_id") "e" ON (("g"."id" = "e"."goat_id")));


ALTER VIEW "public"."v_goat_financials" OWNER TO "postgres";


ALTER TABLE ONLY "public"."caretakers"
    ADD CONSTRAINT "caretakers_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_user_id_tag_number_key" UNIQUE ("user_id", "tag_number");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_expenses_created_at" ON "public"."expenses" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_expenses_expense_date" ON "public"."expenses" USING "btree" ("expense_date" DESC);



CREATE INDEX "idx_expenses_goat" ON "public"."expenses" USING "btree" ("goat_id");



CREATE INDEX "idx_expenses_goat_id" ON "public"."expenses" USING "btree" ("goat_id");



CREATE INDEX "idx_expenses_type" ON "public"."expenses" USING "btree" ("type");



CREATE INDEX "idx_sales_created_at" ON "public"."sales" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_sales_goat_id" ON "public"."sales" USING "btree" ("goat_id");



CREATE INDEX "idx_sales_sale_date" ON "public"."sales" USING "btree" ("sale_date" DESC);



CREATE INDEX "idx_sales_user_id" ON "public"."sales" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "ensure_expense_uuid" BEFORE INSERT ON "public"."expenses" FOR EACH ROW EXECUTE FUNCTION "public"."validate_uuid"();



ALTER TABLE ONLY "public"."caretakers"
    ADD CONSTRAINT "caretakers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."expenses"
    ADD CONSTRAINT "expenses_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_caretaker_id_fkey" FOREIGN KEY ("caretaker_id") REFERENCES "public"."caretakers"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."goats"
    ADD CONSTRAINT "goats_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_goat_id_fkey" FOREIGN KEY ("goat_id") REFERENCES "public"."goats"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."sales"
    ADD CONSTRAINT "sales_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Users can add expenses" ON "public"."expenses" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() IN ( SELECT "goats"."user_id"
   FROM "public"."goats"
  WHERE ("goats"."id" = "expenses"."goat_id"))));



CREATE POLICY "Users can delete their own expenses" ON "public"."expenses" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own goats" ON "public"."goats" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own notifications" ON "public"."notifications" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own sales" ON "public"."sales" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert notifications" ON "public"."notifications" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own expenses" ON "public"."expenses" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own goats" ON "public"."goats" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own sales" ON "public"."sales" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage caretakers" ON "public"."caretakers" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage their goats" ON "public"."goats" TO "authenticated" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can update their own expenses" ON "public"."expenses" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own goats" ON "public"."goats" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own notifications" ON "public"."notifications" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own sales" ON "public"."sales" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view all caretakers" ON "public"."caretakers" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can view their expenses" ON "public"."expenses" FOR SELECT TO "authenticated" USING ((("user_id" = "auth"."uid"()) OR ("auth"."uid"() IN ( SELECT "goats"."user_id"
   FROM "public"."goats"
  WHERE ("goats"."id" = "expenses"."goat_id")))));



CREATE POLICY "Users can view their goats" ON "public"."goats" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view their own expenses" ON "public"."expenses" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own goats" ON "public"."goats" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own notifications" ON "public"."notifications" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own sales" ON "public"."sales" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."caretakers" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."expenses" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."goats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."sales" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."get_financial_summary"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_financial_summary"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_financial_summary"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_financial_summary_v2"("user_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_financial_summary_v2"("user_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_financial_summary_v2"("user_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_uuid"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."is_uuid"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_uuid"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_uuid"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_uuid"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_uuid"() TO "service_role";


















GRANT ALL ON TABLE "public"."caretakers" TO "anon";
GRANT ALL ON TABLE "public"."caretakers" TO "authenticated";
GRANT ALL ON TABLE "public"."caretakers" TO "service_role";



GRANT ALL ON TABLE "public"."expenses" TO "anon";
GRANT ALL ON TABLE "public"."expenses" TO "authenticated";
GRANT ALL ON TABLE "public"."expenses" TO "service_role";



GRANT ALL ON TABLE "public"."goats" TO "anon";
GRANT ALL ON TABLE "public"."goats" TO "authenticated";
GRANT ALL ON TABLE "public"."goats" TO "service_role";



GRANT ALL ON TABLE "public"."sales" TO "anon";
GRANT ALL ON TABLE "public"."sales" TO "authenticated";
GRANT ALL ON TABLE "public"."sales" TO "service_role";



GRANT ALL ON TABLE "public"."caretaker_summary" TO "anon";
GRANT ALL ON TABLE "public"."caretaker_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."caretaker_summary" TO "service_role";



GRANT ALL ON TABLE "public"."caretakers_view" TO "anon";
GRANT ALL ON TABLE "public"."caretakers_view" TO "authenticated";
GRANT ALL ON TABLE "public"."caretakers_view" TO "service_role";



GRANT ALL ON TABLE "public"."expense_summary" TO "anon";
GRANT ALL ON TABLE "public"."expense_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."expense_summary" TO "service_role";



GRANT ALL ON TABLE "public"."goat_expenses" TO "anon";
GRANT ALL ON TABLE "public"."goat_expenses" TO "authenticated";
GRANT ALL ON TABLE "public"."goat_expenses" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."sales_summary" TO "anon";
GRANT ALL ON TABLE "public"."sales_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."sales_summary" TO "service_role";



GRANT ALL ON TABLE "public"."v_caretaker_summary" TO "anon";
GRANT ALL ON TABLE "public"."v_caretaker_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."v_caretaker_summary" TO "service_role";



GRANT ALL ON TABLE "public"."v_goat_financials" TO "anon";
GRANT ALL ON TABLE "public"."v_goat_financials" TO "authenticated";
GRANT ALL ON TABLE "public"."v_goat_financials" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
