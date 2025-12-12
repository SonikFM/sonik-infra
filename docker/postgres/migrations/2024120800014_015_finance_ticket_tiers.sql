-- Sonik OS: Ticket Tiers Table
-- Phase: 2 - Task 2.4
-- Date: 2025-12-08
-- Description: Ticket pricing tiers (GA, VIP, Early Bird, etc.)

CREATE TABLE finance.ticket_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    event_id UUID NOT NULL REFERENCES finance.events(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Tier details
    name TEXT NOT NULL,
    description TEXT,
    tier_type TEXT CHECK (
        tier_type IN ('general_admission', 'vip', 'early_bird', 'late_bird', 'door', 'complimentary', 'staff')
    ),

    -- Pricing
    price_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- Availability
    quantity INTEGER,
    sold INTEGER DEFAULT 0,
    reserved INTEGER DEFAULT 0,

    -- Sales window
    on_sale_at TIMESTAMPTZ,
    off_sale_at TIMESTAMPTZ,

    -- Status
    status TEXT DEFAULT 'active' CHECK (
        status IN ('active', 'paused', 'sold_out', 'archived')
    ),
    is_visible BOOLEAN DEFAULT TRUE,

    -- Display order
    sort_order INTEGER DEFAULT 0,

    -- External IDs
    stripe_price_id TEXT,
    mercadopago_price_id TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_ticket_tiers_event ON finance.ticket_tiers(event_id);
CREATE INDEX idx_ticket_tiers_org ON finance.ticket_tiers(organization_id);
CREATE INDEX idx_ticket_tiers_status ON finance.ticket_tiers(status);
CREATE INDEX idx_ticket_tiers_sort ON finance.ticket_tiers(sort_order);

COMMENT ON TABLE finance.ticket_tiers IS 'Ticket pricing tiers per event';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.ticket_tiers
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
