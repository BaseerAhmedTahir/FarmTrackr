-- Begin transaction
BEGIN;

-- Add new columns to goats table
ALTER TABLE goats 
ADD COLUMN IF NOT EXISTS color TEXT,
ADD COLUMN IF NOT EXISTS markings TEXT,
ADD COLUMN IF NOT EXISTS photo_urls TEXT[],
ADD COLUMN IF NOT EXISTS qr_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS breed TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS purchase_date TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS vendor_name TEXT,
ADD COLUMN IF NOT EXISTS vendor_contact TEXT,
ADD COLUMN IF NOT EXISTS reason_for_sale TEXT,
ADD COLUMN IF NOT EXISTS parent_sire_id UUID REFERENCES goats(id),
ADD COLUMN IF NOT EXISTS parent_dam_id UUID REFERENCES goats(id),
ADD COLUMN IF NOT EXISTS status_log JSONB[] DEFAULT ARRAY[]::JSONB[],
ADD COLUMN IF NOT EXISTS last_weight_kg DECIMAL;

-- Create weight logs table
CREATE TABLE IF NOT EXISTS weight_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    weight_kg DECIMAL NOT NULL CHECK (weight_kg > 0),
    measurement_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create health records table
CREATE TABLE IF NOT EXISTS health_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    record_type TEXT NOT NULL CHECK (record_type IN ('vaccination', 'illness', 'injury', 'deworming', 'treatment', 'checkup')),
    record_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    diagnosis TEXT,
    treatment TEXT,
    medicine TEXT,
    dosage TEXT,
    next_due_date TIMESTAMPTZ,
    vet_name TEXT,
    vet_contact TEXT,
    attachments TEXT[],
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create breeding records table
CREATE TABLE IF NOT EXISTS breeding_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dam_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    sire_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    mating_date TIMESTAMPTZ,
    expected_birth_date TIMESTAMPTZ,
    actual_birth_date TIMESTAMPTZ,
    number_of_kids INTEGER,
    kids_detail JSONB,
    notes TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    goat_id UUID REFERENCES goats(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('vaccination', 'deworming', 'weight_check', 'breeding', 'custom')),
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'dismissed')) DEFAULT 'pending',
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indices for better query performance
CREATE INDEX IF NOT EXISTS idx_weight_logs_goat_id ON weight_logs(goat_id);
CREATE INDEX IF NOT EXISTS idx_weight_logs_date ON weight_logs(measurement_date);
CREATE INDEX IF NOT EXISTS idx_health_records_goat_id ON health_records(goat_id);
CREATE INDEX IF NOT EXISTS idx_health_records_date ON health_records(record_date);
CREATE INDEX IF NOT EXISTS idx_breeding_records_dam_id ON breeding_records(dam_id);
CREATE INDEX IF NOT EXISTS idx_breeding_records_sire_id ON breeding_records(sire_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_due_date ON notifications(due_date);
CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status);

-- Enable RLS on new tables
ALTER TABLE weight_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE breeding_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for weight_logs
CREATE POLICY "Users can view their own weight logs"
ON weight_logs FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own weight logs"
ON weight_logs FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own weight logs"
ON weight_logs FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own weight logs"
ON weight_logs FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create RLS policies for health_records
CREATE POLICY "Users can view their own health records"
ON health_records FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own health records"
ON health_records FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own health records"
ON health_records FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own health records"
ON health_records FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create RLS policies for breeding_records
CREATE POLICY "Users can view their own breeding records"
ON breeding_records FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own breeding records"
ON breeding_records FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own breeding records"
ON breeding_records FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own breeding records"
ON breeding_records FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create RLS policies for notifications
CREATE POLICY "Users can view their own notifications"
ON notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notifications"
ON notifications FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications"
ON notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own notifications"
ON notifications FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Create comprehensive views
CREATE OR REPLACE VIEW v_goat_complete_profile AS
SELECT 
    g.*,
    json_build_object(
        'weights', (
            SELECT json_agg(w.*)
            FROM weight_logs w
            WHERE w.goat_id = g.id
            ORDER BY w.measurement_date DESC
        ),
        'health_records', (
            SELECT json_agg(h.*)
            FROM health_records h
            WHERE h.goat_id = g.id
            ORDER BY h.record_date DESC
        ),
        'breeding_records_as_dam', (
            SELECT json_agg(b.*)
            FROM breeding_records b
            WHERE b.dam_id = g.id
            ORDER BY b.mating_date DESC
        ),
        'breeding_records_as_sire', (
            SELECT json_agg(b.*)
            FROM breeding_records b
            WHERE b.sire_id = g.id
            ORDER BY b.mating_date DESC
        ),
        'notifications', (
            SELECT json_agg(n.*)
            FROM notifications n
            WHERE n.goat_id = g.id AND n.status = 'pending'
            ORDER BY n.due_date ASC
        )
    ) as related_records,
    c.name as caretaker_name,
    c.phone as caretaker_contact,
    u.email as owner_email
FROM goats g
LEFT JOIN caretakers c ON g.caretaker_id = c.id
LEFT JOIN auth.users u ON g.user_id = u.id;

-- Function to update goat status with logging
CREATE OR REPLACE FUNCTION update_goat_status(
    goat_id UUID,
    new_status goat_status,
    reason TEXT DEFAULT NULL
) RETURNS void AS $$
DECLARE
    old_status goat_status;
BEGIN
    -- Get current status
    SELECT status INTO old_status FROM goats WHERE id = goat_id;
    
    -- Update status
    UPDATE goats 
    SET 
        status = new_status,
        status_log = array_append(
            status_log, 
            jsonb_build_object(
                'from', old_status,
                'to', new_status,
                'timestamp', NOW(),
                'reason', reason,
                'user_id', auth.uid()
            )
        )
    WHERE id = goat_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add function to generate QR codes for goats
CREATE OR REPLACE FUNCTION generate_goat_qr_code(goat_tag TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Simple concatenation for now - in practice you might want to use a more sophisticated method
    RETURN 'gt_' || regexp_replace(goat_tag, '[^a-zA-Z0-9]', '', 'g');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Update existing goats with QR codes if they don't have one
UPDATE goats
SET qr_code = generate_goat_qr_code(tag_number)
WHERE qr_code IS NULL;

-- Create trigger to automatically generate QR code for new goats
CREATE OR REPLACE FUNCTION set_goat_qr_code()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.qr_code IS NULL THEN
        NEW.qr_code := generate_goat_qr_code(NEW.tag_number);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_set_goat_qr_code
BEFORE INSERT ON goats
FOR EACH ROW
EXECUTE FUNCTION set_goat_qr_code();

COMMIT;
