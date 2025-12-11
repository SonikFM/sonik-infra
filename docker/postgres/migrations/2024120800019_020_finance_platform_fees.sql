-- Sonik OS: Platform Fees Table
-- Phase: 2 - Task 2.9
-- Date: 2025-12-08
-- Description: Sonik platform revenue tracking (with UUIDv7)
-- Updates: Addendum schema with UUIDv7 for time-ordering

CREATE TABLE finance.platform_fees (
    id UUID PRIMARY KEY DEFAULT uuidv7(),  -- Changed from gen_random_uuid()

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Source
    transaction_id UUID REFERENCES finance.transactions(id),
    event_id UUID REFERENCES finance.events(id),

    -- Fee details
    fee_type TEXT NOT NULL CHECK (
        fee_type IN ('ticket_fee', 'service_fee', 'processing_fee', 'payout_fee', 'subscription', 'other')
    ),
    amount_cents BIGINT NOT NULL,
    currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- USD conversion
    usd_amount_cents BIGINT,
    fx_rate_to_usd DECIMAL(18,8),

    -- Description
    description TEXT,

    -- Status
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'collected', 'waived', 'refunded')),

    -- Timestamps
    fee_date DATE NOT NULL DEFAULT CURRENT_DATE,
    collected_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_platform_fees_org ON finance.platform_fees(organization_id);
CREATE INDEX idx_platform_fees_txn ON finance.platform_fees(transaction_id);
CREATE INDEX idx_platform_fees_date ON finance.platform_fees(fee_date);
CREATE INDEX idx_platform_fees_type ON finance.platform_fees(fee_type);

COMMENT ON TABLE finance.platform_fees IS 'Sonik platform revenue with UUIDv7 for time-ordering';
