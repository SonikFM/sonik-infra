-- Sonik OS: Organizations Table (THE HUB)
-- Phase: 1 - Task 1.7
-- Date: 2025-12-08
-- Description: CRITICAL first-class hub table - all org-scoped tables reference this

CREATE TABLE market.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    legal_name TEXT,
    tax_id TEXT,

    -- Type
    organization_type TEXT NOT NULL CHECK (
        organization_type IN ('promoter', 'venue', 'festival', 'agency', 'brand', 'other')
    ),

    -- Contact
    email TEXT,
    phone TEXT,
    website TEXT,

    -- Location
    country_code TEXT REFERENCES shared.countries(code),
    city TEXT,
    address TEXT,

    -- Settings
    default_currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),
    timezone TEXT DEFAULT 'America/Bogota',
    locale TEXT DEFAULT 'es',

    -- Sonik Relationship
    sonik_relationship TEXT CHECK (
        sonik_relationship IS NULL
        OR sonik_relationship IN ('owned', 'partner', 'customer', 'prospect', 'churned')
    ),
    contract_start_date DATE,
    contract_end_date DATE,
    revenue_share_percent DECIMAL(5,2),

    -- Branding
    logo_url TEXT,
    brand_color TEXT,

    -- External IDs
    stripe_account_id TEXT,
    mercadopago_account_id TEXT,
    twenty_crm_id TEXT,
    directus_id TEXT,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    verified_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_orgs_slug ON market.organizations(slug);
CREATE INDEX idx_orgs_type ON market.organizations(organization_type);
CREATE INDEX idx_orgs_status ON market.organizations(status);
CREATE INDEX idx_orgs_country ON market.organizations(country_code);
CREATE INDEX idx_orgs_stripe ON market.organizations(stripe_account_id);

-- UNIQUE constraints on external IDs (allow NULL, enforce uniqueness on non-NULL)
CREATE UNIQUE INDEX idx_orgs_stripe_unique
    ON market.organizations(stripe_account_id)
    WHERE stripe_account_id IS NOT NULL;

CREATE UNIQUE INDEX idx_orgs_mp_unique
    ON market.organizations(mercadopago_account_id)
    WHERE mercadopago_account_id IS NOT NULL;

CREATE UNIQUE INDEX idx_orgs_twenty_unique
    ON market.organizations(twenty_crm_id)
    WHERE twenty_crm_id IS NOT NULL;

CREATE UNIQUE INDEX idx_orgs_directus_unique
    ON market.organizations(directus_id)
    WHERE directus_id IS NOT NULL;

COMMENT ON TABLE market.organizations IS 'FIRST-CLASS HUB: All org-scoped tables reference this via organization_id';
