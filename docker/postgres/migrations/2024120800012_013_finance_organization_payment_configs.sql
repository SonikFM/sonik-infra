-- Sonik OS: Organization Payment Configs Table
-- Phase: 2 - Task 2.2
-- Date: 2025-12-08
-- Description: Per-organization payment processor configurations

CREATE TABLE finance.organization_payment_configs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id) ON DELETE CASCADE,

    -- Processor
    processor_code TEXT NOT NULL REFERENCES finance.payment_processors(code),

    -- Configuration
    is_active BOOLEAN DEFAULT TRUE,
    is_primary BOOLEAN DEFAULT FALSE,

    -- Credentials (encrypted in production)
    api_key TEXT,
    api_secret TEXT,
    webhook_secret TEXT,
    config JSONB DEFAULT '{}',

    -- Fee structure (override processor defaults)
    platform_fee_percent DECIMAL(5,2),
    platform_fee_fixed_cents INTEGER,

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'active', 'suspended', 'disabled')
    ),
    verified_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(organization_id, processor_code)
);

-- Indexes
CREATE INDEX idx_org_payment_configs_org ON finance.organization_payment_configs(organization_id);
CREATE INDEX idx_org_payment_configs_processor ON finance.organization_payment_configs(processor_code);
CREATE INDEX idx_org_payment_configs_active ON finance.organization_payment_configs(is_active);

COMMENT ON TABLE finance.organization_payment_configs IS 'Per-organization payment processor credentials and settings';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.organization_payment_configs
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
