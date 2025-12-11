-- Sonik OS: Users Table
-- Phase: 1 - Task 1.4
-- Date: 2025-12-08
-- Description: Platform-level user identities (single source of truth)

CREATE TABLE shared.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    email TEXT UNIQUE,
    phone TEXT,
    name TEXT,
    photo_url TEXT,

    -- Authentication (Supabase Auth integration)
    supabase_auth_id UUID UNIQUE,

    -- Location
    city TEXT,
    region TEXT,
    country_code TEXT REFERENCES shared.countries(code),

    -- Localization
    locale TEXT DEFAULT 'es',
    timezone TEXT DEFAULT 'America/Bogota',
    preferred_currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- External IDs
    twenty_crm_id TEXT,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended', 'deleted')),
    email_verified_at TIMESTAMPTZ,
    phone_verified_at TIMESTAMPTZ,

    -- Privacy
    gdpr_consent_at TIMESTAMPTZ,
    marketing_consent BOOLEAN DEFAULT FALSE,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_users_email ON shared.users(email);
CREATE INDEX idx_users_phone ON shared.users(phone);
CREATE INDEX idx_users_supabase_auth ON shared.users(supabase_auth_id);
CREATE INDEX idx_users_status ON shared.users(status);
CREATE INDEX idx_users_country ON shared.users(country_code);
CREATE INDEX idx_users_twenty ON shared.users(twenty_crm_id);

COMMENT ON TABLE shared.users IS 'Platform-level user identities - single source of truth';
