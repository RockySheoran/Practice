-- ===== CREATE SCHEMA =====
CREATE SCHEMA IF NOT EXISTS identity AUTHORIZATION lifeflow;
SET search_path TO identity, public;

-- ===== ENUMS =====
CREATE TYPE user_type_enum AS ENUM ('DONOR', 'HOSPITAL', 'BLOOD_BANK', 'ADMIN', 'SYSTEM_ADMIN');
CREATE TYPE user_status_enum AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'DELETED');
CREATE TYPE document_type_enum AS ENUM ('AADHAR', 'PAN', 'VOTER_ID', 'PASSPORT', 'DRIVER_LICENSE', 'OTHER');
CREATE TYPE document_status_enum AS ENUM ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED');
CREATE TYPE two_fa_method_enum AS ENUM ('SMS', 'EMAIL', 'AUTHENTICATOR_APP', 'HARDWARE_TOKEN');
CREATE TYPE audit_action_enum AS ENUM ('LOGIN', 'LOGOUT', 'PASSWORD_CHANGE', 'EMAIL_VERIFICATION', '2FA_ENABLED', '2FA_DISABLED', 'ACCOUNT_CREATION', 'ACCOUNT_DELETION', 'ROLE_CHANGE', 'PERMISSION_CHANGE', 'KYC_UPLOAD', 'KYC_VERIFICATION', 'PASSWORD_RESET', 'LOGIN_FAILED', 'SUSPICIOUS_ACTIVITY');
CREATE TYPE audit_status_enum AS ENUM ('SUCCESS', 'FAILURE', 'PENDING');

-- ===== USERS TABLE =====
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    profile_picture_url VARCHAR(500),
    user_type user_type_enum NOT NULL DEFAULT 'DONOR',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    status user_status_enum DEFAULT 'INACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ===== ROLES TABLE =====
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (role_name, description) VALUES
('DONOR', 'Blood donor role'),
('HOSPITAL_STAFF', 'Hospital staff role'),
('BLOOD_BANK_MANAGER', 'Blood bank manager role'),
('ADMIN', 'System administrator role'),
('SYSTEM_ADMIN', 'System administrator with full access');

-- ===== USER_ROLES TABLE =====
CREATE TABLE user_roles (
    user_role_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(user_id),
    
    UNIQUE(user_id, role_id)
);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- ===== KYC_DOCUMENTS TABLE =====
CREATE TABLE kyc_documents (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    document_type document_type_enum NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    document_number VARCHAR(100),
    status document_status_enum DEFAULT 'PENDING',
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(user_id),
    expiry_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    rejection_reason TEXT
);

CREATE INDEX idx_kyc_documents_user_id ON kyc_documents(user_id);
CREATE INDEX idx_kyc_documents_status ON kyc_documents(status);
CREATE INDEX idx_kyc_documents_document_type ON kyc_documents(document_type);

-- ===== SESSIONS TABLE =====
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    access_token VARCHAR(2000) NOT NULL,
    refresh_token VARCHAR(2000),
    token_expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    refresh_token_expiry TIMESTAMP WITH TIME ZONE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    device_id VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    logged_out_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_access_token ON sessions(access_token);
CREATE INDEX idx_sessions_is_active ON sessions(is_active);
CREATE INDEX idx_sessions_token_expiry ON sessions(token_expiry);

-- ===== TWO_FA_SECRETS TABLE =====
CREATE TABLE two_fa_secrets (
    secret_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE UNIQUE,
    secret_key TEXT NOT NULL, -- encrypted
    method two_fa_method_enum NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    is_enabled BOOLEAN DEFAULT false,
    backup_codes TEXT[], -- encrypted array
    backup_codes_used BOOLEAN[] DEFAULT '{false,false,false,false,false,false,false,false,false,false}',
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_two_fa_secrets_user_id ON two_fa_secrets(user_id);

-- ===== OAUTH_CLIENTS TABLE =====
CREATE TABLE oauth_clients (
    client_id VARCHAR(255) PRIMARY KEY,
    client_secret VARCHAR(255) NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    redirect_urls TEXT[] NOT NULL,
    allowed_scopes TEXT[] NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_confidential BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(user_id)
);

-- ===== AUDIT_LOGS TABLE =====
CREATE TABLE audit_logs (
    audit_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    action audit_action_enum NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    old_value JSONB,
    new_value JSONB,
    details JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    status audit_status_enum NOT NULL DEFAULT 'SUCCESS',
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);

-- ===== PASSWORD_RESET_TOKENS TABLE =====
CREATE TABLE password_reset_tokens (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT false,
    used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

-- ===== EMAIL_VERIFICATION_TOKENS TABLE =====
CREATE TABLE email_verification_tokens (
    token_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX idx_email_verification_tokens_email ON email_verification_tokens(email);
