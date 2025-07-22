-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types for health records
CREATE TYPE health_record_type AS ENUM ('vaccination', 'illness', 'injury', 'deworming', 'other');
CREATE TYPE health_status AS ENUM ('healthy', 'under_treatment', 'recovered', 'deceased');

-- Create weight_logs table
CREATE TABLE IF NOT EXISTS weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id) ON DELETE CASCADE,
    weight_kg DECIMAL NOT NULL,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    CONSTRAINT positive_weight CHECK (weight_kg > 0)
);

-- Create health_records table
CREATE TABLE IF NOT EXISTS health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id) ON DELETE CASCADE,
    record_type health_record_type NOT NULL,
    record_date DATE NOT NULL,
    diagnosis TEXT,
    treatment TEXT,
    medicine TEXT,
    dosage TEXT,
    next_due_date DATE,
    vet_name TEXT,
    status health_status NOT NULL DEFAULT 'healthy',
    notes TEXT,
    attachments TEXT[],
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create breeding_records table
CREATE TABLE IF NOT EXISTS breeding_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id) ON DELETE CASCADE,
    partner_goat_id UUID REFERENCES goats(id),
    breeding_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    kids_born INTEGER,
    kids_survived INTEGER,
    notes TEXT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_kids CHECK (kids_survived <= kids_born),
    CONSTRAINT different_goats CHECK (goat_id != partner_goat_id)
);

-- Create qr_codes table for QR code tracking
CREATE TABLE IF NOT EXISTS qr_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID NOT NULL REFERENCES goats(id) ON DELETE CASCADE,
    code TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_goat_qr UNIQUE (goat_id)
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    due_date DATE,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_weight_logs_goat ON weight_logs(goat_id);
CREATE INDEX IF NOT EXISTS idx_weight_logs_user ON weight_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_goat ON health_records(goat_id);
CREATE INDEX IF NOT EXISTS idx_health_records_user ON health_records(user_id);
CREATE INDEX IF NOT EXISTS idx_health_records_type ON health_records(record_type);
CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(record_date);
CREATE INDEX IF NOT EXISTS idx_breeding_records_goat ON breeding_records(goat_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_partner ON breeding_records(partner_goat_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_user ON breeding_records(user_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_date ON breeding_records(breeding_date);
CREATE INDEX IF NOT EXISTS idx_qr_codes_goat ON qr_codes(goat_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_goat ON notifications(goat_id);
CREATE INDEX IF NOT EXISTS idx_notifications_due_date ON notifications(due_date);

-- Add triggers for automatic notification creation
CREATE OR REPLACE FUNCTION create_health_record_notification()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.next_due_date IS NOT NULL THEN
        INSERT INTO notifications (user_id, goat_id, title, message, type, due_date)
        VALUES (
            NEW.user_id,
            NEW.goat_id,
            CASE NEW.record_type
                WHEN 'vaccination' THEN 'Vaccination Due'
                WHEN 'deworming' THEN 'Deworming Due'
                ELSE 'Health Check Due'
            END,
            'Health record follow-up required for goat ' || (SELECT tag_number FROM goats WHERE id = NEW.goat_id),
            NEW.record_type::TEXT,
            NEW.next_due_date
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER health_record_notification_trigger
AFTER INSERT ON health_records
FOR EACH ROW
EXECUTE FUNCTION create_health_record_notification();

-- Add function to generate QR code on goat creation
CREATE OR REPLACE FUNCTION generate_qr_code()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO qr_codes (goat_id, code)
    VALUES (NEW.id, 'GT-' || REPLACE(NEW.id::TEXT, '-', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER goat_qr_code_trigger
AFTER INSERT ON goats
FOR EACH ROW
EXECUTE FUNCTION generate_qr_code();
