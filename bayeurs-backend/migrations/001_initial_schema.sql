sql
-- ============================================
-- BAYEURS APPLICATION - INITIAL SCHEMA
-- ============================================

-- DROP existing tables if they exist (for development only)
DROP TABLE IF EXISTS ratings CASCADE;
DROP TABLE IF EXISTS bills CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS maintenance_requests CASCADE;
DROP TABLE IF EXISTS maintenances CASCADE;
DROP TABLE IF EXISTS property_technicians CASCADE;
DROP TABLE IF EXISTS technicians CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS leases CASCADE;
DROP TABLE IF EXISTS property_images CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS delegations CASCADE;
DROP TABLE IF EXISTS verification_codes CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- 1. USERS TABLE
-- ============================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('TENANT', 'LANDLORD', 'OWNER', 'TECHNICIAN')),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    avatar_url VARCHAR(500),
    bio TEXT,
    rating DECIMAL(3, 2) DEFAULT 0,
    total_ratings INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- ============================================
-- 2. VERIFICATION CODES TABLE
-- ============================================

CREATE TABLE verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('EMAIL', 'PHONE')),
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    attempts INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_verification_user ON verification_codes(user_id);
CREATE INDEX idx_verification_code ON verification_codes(code);
CREATE INDEX idx_verification_expires ON verification_codes(expires_at);

-- ============================================
-- 3. DELEGATIONS TABLE
-- ============================================

CREATE TABLE delegations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    delegate_email VARCHAR(100) NOT NULL,
    invitation_code VARCHAR(50) UNIQUE NOT NULL,
    invitation_expires_at TIMESTAMP NOT NULL,
    accepted_at TIMESTAMP,
    delegate_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED', 'REVOKED')),
    permissions TEXT[] DEFAULT ARRAY['MANAGE_LEASES', 'MANAGE_PAYMENTS', 'MANAGE_MAINTENANCE'],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_delegations_owner ON delegations(owner_id);
CREATE INDEX idx_delegations_delegate ON delegations(delegate_id);
CREATE INDEX idx_delegations_code ON delegations(invitation_code);
CREATE INDEX idx_delegations_status ON delegations(status);

-- ============================================
-- 4. PROPERTIES TABLE
-- ============================================

CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(500) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    type VARCHAR(50) NOT NULL CHECK (type IN ('HOUSE', 'APARTMENT', 'STUDIO', 'ROOM', 'BUILDING')),
    sale_price DECIMAL(15, 2),
    rent_price DECIMAL(10, 2),
    status VARCHAR(50) NOT NULL CHECK (status IN ('FOR_SALE', 'FOR_RENT', 'SOLD', 'OCCUPIED')),
    standing VARCHAR(50) NOT NULL CHECK (standing IN ('SIMPLE', 'STANDARD', 'LUXURY')),
    description TEXT,
    verification_status VARCHAR(50) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    verification_document_url VARCHAR(500),
    image_urls TEXT[],
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_properties_owner ON properties(owner_id);
CREATE INDEX idx_properties_status ON properties(status);
CREATE INDEX idx_properties_location ON properties(location);
CREATE INDEX idx_properties_type ON properties(type);
CREATE INDEX idx_properties_created_at ON properties(created_at DESC);
CREATE INDEX idx_properties_verification ON properties(verification_status);

-- ============================================
-- 5. PROPERTY IMAGES TABLE
-- ============================================

CREATE TABLE property_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_property_images_property ON property_images(property_id);

-- ============================================
-- 6. LEASES TABLE
-- ============================================

CREATE TABLE leases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    monthly_rent DECIMAL(10, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    contract_text TEXT NOT NULL,
    tenant_signature VARCHAR(500),
    tenant_signature_date TIMESTAMP,
    landlord_signature VARCHAR(500),
    landlord_signature_date TIMESTAMP,
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACTIVE', 'EXPIRED', 'TERMINATED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_leases_property ON leases(property_id);
CREATE INDEX idx_leases_tenant ON leases(tenant_id);
CREATE INDEX idx_leases_landlord ON leases(landlord_id);
CREATE INDEX idx_leases_status ON leases(status);
CREATE INDEX idx_leases_created_at ON leases(created_at DESC);

-- ============================================
-- 7. PAYMENTS TABLE
-- ============================================

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lease_id UUID NOT NULL REFERENCES leases(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('MOBILE_MONEY', 'BANK_TRANSFER', 'CARD', 'MANUAL')),
    provider VARCHAR(50) NOT NULL CHECK (provider IN ('ORANGE_MONEY', 'MTN_MONEY', 'AITEL', 'VISA', 'MASTERCARD', 'PAYPAL', 'BANK_TRANSFER', 'OTHER')),
    reference_number VARCHAR(100) UNIQUE,
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED')),
    invoice_url VARCHAR(500),
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_lease ON payments(lease_id);
CREATE INDEX idx_payments_tenant ON payments(tenant_id);
CREATE INDEX idx_payments_landlord ON payments(landlord_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at DESC);

-- ============================================
-- 8. TECHNICIANS TABLE
-- ============================================

CREATE TABLE technicians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    specialty VARCHAR(50) NOT NULL CHECK (specialty IN ('ELECTRICITY', 'PLUMBING', 'GENERAL')),
    years_experience INTEGER,
    qualification_document_url VARCHAR(500),
    license_number VARCHAR(100),
    verification_status VARCHAR(50) DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'APPROVED', 'REJECTED')),
    service_area VARCHAR(500),
    is_available BOOLEAN DEFAULT TRUE,
    average_rating DECIMAL(3, 2) DEFAULT 0,
    total_ratings INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_technicians_user ON technicians(user_id);
CREATE INDEX idx_technicians_specialty ON technicians(specialty);
CREATE INDEX idx_technicians_status ON technicians(verification_status);
CREATE INDEX idx_technicians_available ON technicians(is_available);

-- ============================================
-- 9. PROPERTY TECHNICIANS TABLE
-- ============================================

CREATE TABLE property_technicians (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    technician_id UUID NOT NULL REFERENCES technicians(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(property_id, technician_id)
);

CREATE INDEX idx_property_technicians_property ON property_technicians(property_id);
CREATE INDEX idx_property_technicians_tech ON property_technicians(technician_id);

-- ============================================
-- 10. MAINTENANCES TABLE
-- ============================================

CREATE TABLE maintenances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    technician_id UUID REFERENCES technicians(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('ELECTRICITY', 'PLUMBING', 'GENERAL')),
    frequency VARCHAR(50) NOT NULL CHECK (frequency IN ('WEEKLY', 'MONTHLY', 'YEARLY', 'ONCE')),
    start_date DATE NOT NULL,
    next_scheduled_date DATE NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'SCHEDULED' CHECK (status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_maintenance_property ON maintenances(property_id);
CREATE INDEX idx_maintenance_tech ON maintenances(technician_id);
CREATE INDEX idx_maintenance_status ON maintenances(status);
CREATE INDEX idx_maintenance_next_date ON maintenances(next_scheduled_date);

-- ============================================
-- 11. MAINTENANCE REQUESTS TABLE
-- ============================================

CREATE TABLE maintenance_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    tenant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('ELECTRICITY', 'PLUMBING', 'GENERAL')),
    description TEXT NOT NULL,
    urgency VARCHAR(50) DEFAULT 'NORMAL' CHECK (urgency IN ('NORMAL', 'URGENT')),
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'REJECTED')),
    photos TEXT[],
    assigned_technician_id UUID REFERENCES technicians(id) ON DELETE SET NULL,
    completion_notes TEXT,
    completion_photos TEXT[],
    estimated_cost DECIMAL(10, 2),
    actual_cost DECIMAL(10, 2),
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_maintenance_req_property ON maintenance_requests(property_id);
CREATE INDEX idx_maintenance_req_tenant ON maintenance_requests(tenant_id);
CREATE INDEX idx_maintenance_req_status ON maintenance_requests(status);
CREATE INDEX idx_maintenance_req_urgency ON maintenance_requests(urgency);

-- ============================================
-- 12. MESSAGES TABLE
-- ============================================

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(50) DEFAULT 'TEXT' CHECK (message_type IN ('TEXT', 'IMAGE', 'FILE')),
    attachment_url VARCHAR(500),
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_receiver ON messages(receiver_id);
CREATE INDEX idx_messages_property ON messages(property_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);
CREATE INDEX idx_messages_unread ON messages(receiver_id, read_at);

-- ============================================
-- 13. COMMENTS TABLE
-- ============================================

CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    dislikes_count INTEGER DEFAULT 0,
    parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    is_reported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_comments_property ON comments(property_id);
CREATE INDEX idx_comments_user ON comments(user_id);
CREATE INDEX idx_comments_parent ON comments(parent_comment_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);

-- ============================================
-- 14. BILLS TABLE
-- ============================================

CREATE TABLE bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id) ON DELETE SET NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('ELECTRICITY', 'WATER', 'CANAL_PLUS', 'DSTV', 'STARS', 'NETFLIX', 'PRIME_VIDEO', 'OTHER')),
    amount DECIMAL(10, 2) NOT NULL,
    period_start DATE,
    period_end DATE,
    renewal_date DATE,
    status VARCHAR(50) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'OVERDUE')),
    document_url VARCHAR(500),
    payment_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_bills_tenant ON bills(tenant_id);
CREATE INDEX idx_bills_type ON bills(type);
CREATE INDEX idx_bills_status ON bills(status);
CREATE INDEX idx_bills_renewal_date ON bills(renewal_date);

-- ============================================
-- 15. RATINGS TABLE
-- ============================================

CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rater_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rated_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    maintenance_request_id UUID REFERENCES maintenance_requests(id) ON DELETE SET NULL,
    lease_id UUID REFERENCES leases(id) ON DELETE SET NULL,
    rating DECIMAL(3, 2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ratings_rater ON ratings(rater_id);
CREATE INDEX idx_ratings_rated ON ratings(rated_user_id);
CREATE INDEX idx_ratings_maintenance ON ratings(maintenance_request_id);

-- ============================================
-- SECURITY IMPROVEMENTS
-- ============================================

-- Update ratings in users table when a new rating is created
CREATE OR REPLACE FUNCTION update_user_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE users 
  SET rating = (
    SELECT AVG(rating) FROM ratings WHERE rated_user_id = NEW.rated_user_id
  ),
  total_ratings = (
    SELECT COUNT(*) FROM ratings WHERE rated_user_id = NEW.rated_user_id
  )
  WHERE id = NEW.rated_user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_rating
AFTER INSERT ON ratings
FOR EACH ROW
EXECUTE FUNCTION update_user_rating();

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Uncomment to add sample data
/*
-- Sample user (password: 123456789)
INSERT INTO users (username, email, phone_number, password_hash, role, email_verified, phone_verified)
VALUES ('john_landlord', 'john@example.com', '+237671234567', '$2b$10$hashedpassword', 'LANDLORD', TRUE, TRUE);

-- Sample property
INSERT INTO properties (owner_id, name, location, type, rent_price, status, standing, description)
SELECT id, 'Beautiful Apartment', 'Douala, Littoral', 'APARTMENT', 150000, 'FOR_RENT', 'STANDARD', '2 bedroom apartment'
FROM users WHERE email = 'john@example.com'
LIMIT 1;
*/

-- ============================================
-- FINAL CHECK
-- ============================================

-- List all tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;