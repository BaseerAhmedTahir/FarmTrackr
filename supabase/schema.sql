-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE payment_mode AS ENUM ('cash', 'bank', 'upi');
CREATE TYPE payment_type AS ENUM ('fixed', 'share');
CREATE TYPE expense_type AS ENUM ('feed', 'medicine', 'transport', 'other');
CREATE TYPE goat_status AS ENUM ('active', 'sold', 'dead');

-- Create tables
CREATE TABLE caretakers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    phone TEXT,
    location TEXT,
    payment_type payment_type NOT NULL,
    profit_share_pct DECIMAL,
    monthly_fee DECIMAL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT valid_payment CHECK (
        (payment_type = 'share' AND profit_share_pct IS NOT NULL) OR
        (payment_type = 'fixed' AND monthly_fee IS NOT NULL)
    )
);

CREATE TABLE goats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tag_number TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    price DECIMAL NOT NULL,
    photo_url TEXT,
    status goat_status NOT NULL DEFAULT 'active',
    caretaker_id UUID REFERENCES caretakers(id),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    gender TEXT NOT NULL,
    breed TEXT,
    sale_price DECIMAL,
    CONSTRAINT positive_price CHECK (price > 0),
    CONSTRAINT valid_sale_price CHECK (sale_price IS NULL OR sale_price > 0)
);

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type expense_type NOT NULL,
    amount DECIMAL NOT NULL,
    date DATE NOT NULL,
    goat_id UUID REFERENCES goats(id) ON DELETE SET NULL,
    notes TEXT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT positive_amount CHECK (amount > 0)
);

CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id),
    sale_price DECIMAL NOT NULL,
    buyer_name TEXT,
    payment_mode payment_mode NOT NULL,
    sale_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT positive_sale_price CHECK (sale_price > 0)
);

CREATE TABLE weights (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id) ON DELETE CASCADE,
    weight_kg DECIMAL NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT positive_weight CHECK (weight_kg > 0)
);

CREATE TABLE goat_births (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_goat_id UUID NOT NULL REFERENCES goats(id),
    parent_goat_id UUID NOT NULL REFERENCES goats(id),
    birth_date DATE NOT NULL,
    CONSTRAINT different_goats CHECK (child_goat_id != parent_goat_id)
);

-- Create indexes
CREATE INDEX idx_goats_user ON goats(user_id);
CREATE INDEX idx_goats_caretaker ON goats(caretaker_id);
CREATE INDEX idx_expenses_user ON expenses(user_id);
CREATE INDEX idx_expenses_goat ON expenses(goat_id);
CREATE INDEX idx_weights_goat ON weights(goat_id);

-- Create functions for common operations
CREATE OR REPLACE FUNCTION calculate_financial_summary(p_user_id UUID)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE
    result json;
BEGIN
    WITH goat_expenses AS (
        SELECT goat_id, COALESCE(SUM(amount), 0) as total_expenses
        FROM expenses
        WHERE user_id = p_user_id
        GROUP BY goat_id
    ),
    summary AS (
        SELECT 
            COUNT(*) FILTER (WHERE status = 'active') as active_goats,
            COUNT(*) FILTER (WHERE status = 'sold') as sold_goats,
            COUNT(*) FILTER (WHERE status = 'dead') as dead_goats,
            COALESCE(SUM(price), 0) as total_investment,
            COALESCE(SUM(CASE WHEN status = 'sold' THEN sale_price ELSE 0 END), 0) as total_sales,
            COALESCE(SUM(CASE 
                WHEN status = 'sold' 
                THEN sale_price - price - COALESCE(ge.total_expenses, 0)
                ELSE 0 
            END), 0) as total_profit
        FROM goats g
        LEFT JOIN goat_expenses ge ON g.id = ge.goat_id
        WHERE g.user_id = p_user_id
    )
    SELECT json_build_object(
        'active_goats', active_goats,
        'sold_goats', sold_goats,
        'dead_goats', dead_goats,
        'total_investment', total_investment,
        'total_sales', total_sales,
        'total_profit', total_profit
    ) INTO result
    FROM summary;
    
    RETURN result;
END;
$$;

-- Function to record a goat sale with transaction
CREATE OR REPLACE FUNCTION record_goat_sale(
    p_goat_id UUID,
    p_sale_price DECIMAL,
    p_buyer_name TEXT,
    p_payment_mode payment_mode,
    p_notes TEXT,
    p_user_id UUID
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    -- Start transaction
    BEGIN
        -- Check if goat exists and belongs to user
        IF NOT EXISTS (
            SELECT 1 FROM goats 
            WHERE id = p_goat_id AND user_id = p_user_id AND status = 'active'
        ) THEN
            RAISE EXCEPTION 'Invalid goat ID or goat not available for sale';
        END IF;

        -- Insert sale record
        INSERT INTO sales (
            goat_id, 
            sale_price, 
            buyer_name, 
            payment_mode,
            sale_date,
            notes
        ) VALUES (
            p_goat_id,
            p_sale_price,
            p_buyer_name,
            p_payment_mode,
            CURRENT_DATE,
            p_notes
        );

        -- Update goat status
        UPDATE goats 
        SET status = 'sold',
            sale_price = p_sale_price
        WHERE id = p_goat_id;

        -- Commit transaction happens automatically
    EXCEPTION
        WHEN others THEN
            -- Rollback happens automatically
            RAISE;
    END;
END;
$$;

-- Row Level Security Policies
ALTER TABLE goats ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE caretakers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE weights ENABLE ROW LEVEL SECURITY;
ALTER TABLE goat_births ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can see their own data" ON goats
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can see their own expenses" ON expenses
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can see their own caretakers" ON caretakers
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can see sales of their goats" ON sales
    FOR ALL USING (
        goat_id IN (
            SELECT id FROM goats WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can see weights of their goats" ON weights
    FOR ALL USING (
        goat_id IN (
            SELECT id FROM goats WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can see births of their goats" ON goat_births
    FOR ALL USING (
        child_goat_id IN (
            SELECT id FROM goats WHERE user_id = auth.uid()
        )
    );
