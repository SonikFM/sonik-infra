-- Sonik OS: Customers Table
-- Phase: 1 - Task 1.7b (from Addendum)
-- Date: 2025-12-08
-- Description: Org-scoped customer profiles - one record per user-org relationship

CREATE TABLE market.customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    user_id UUID NOT NULL REFERENCES shared.users(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES market.organizations(id) ON DELETE CASCADE,

    -- Denormalized from User (for fast org-scoped queries)
    name TEXT,
    email TEXT,
    phone TEXT,
    photo_url TEXT,

    -- Location (denormalized)
    city TEXT,
    region TEXT,
    country_code TEXT REFERENCES shared.countries(code),

    -- Behavioral tracking (org-specific)
    ticket_count INTEGER DEFAULT 0,
    total_spent_cents BIGINT DEFAULT 0,
    currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),
    tags TEXT[],

    -- Purchase history
    first_purchase_at TIMESTAMPTZ,
    last_purchase_at TIMESTAMPTZ,
    events_attended_count INTEGER DEFAULT 0,

    -- Notification preferences (org-specific)
    notification_preferences JSONB DEFAULT '{
        "promotional": {"sms": true, "email": true, "whatsapp": true},
        "transactional": {"sms": true, "email": true, "whatsapp": true},
        "events": {"sms": true, "email": true, "whatsapp": true}
    }',

    -- Customer type
    customer_type TEXT CHECK (customer_type IS NULL OR customer_type IN ('regular', 'vip', 'staff', 'press', 'comp')),

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(user_id, organization_id)  -- One customer record per user-org pair
);

-- Indexes
CREATE INDEX idx_customers_user ON market.customers(user_id);
CREATE INDEX idx_customers_org ON market.customers(organization_id);
CREATE INDEX idx_customers_email ON market.customers(email);
CREATE INDEX idx_customers_phone ON market.customers(phone);
CREATE INDEX idx_customers_last_purchase ON market.customers(last_purchase_at);

COMMENT ON TABLE market.customers IS 'Org-scoped customer profiles - one record per user-org relationship';
