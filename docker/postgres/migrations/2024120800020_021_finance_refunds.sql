-- Sonik OS: Refunds Table
-- Phase: 2 - Task 2.10
-- Date: 2025-12-08
-- Description: Refund records (with UUIDv7)
-- Updates: Addendum schema with UUIDv7 for time-ordering

CREATE TABLE finance.refunds (
    id UUID PRIMARY KEY DEFAULT uuidv7(),  -- Changed from gen_random_uuid()

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Original transaction
    transaction_id UUID NOT NULL REFERENCES finance.transactions(id),

    -- Amount (native currency)
    amount_cents BIGINT NOT NULL,
    currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- USD conversion
    usd_amount_cents BIGINT,
    fx_rate_to_usd DECIMAL(18,8),

    -- Reason
    reason TEXT CHECK (
        reason IN ('customer_request', 'event_cancelled', 'event_postponed', 'duplicate', 'fraud', 'other')
    ),
    reason_details TEXT,

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'completed', 'failed')
    ),

    -- Processor
    processor_refund_id TEXT,

    -- Timestamps
    requested_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_refunds_org ON finance.refunds(organization_id);
CREATE INDEX idx_refunds_txn ON finance.refunds(transaction_id);
CREATE INDEX idx_refunds_status ON finance.refunds(status);
CREATE INDEX idx_refunds_requested ON finance.refunds(requested_at);

COMMENT ON TABLE finance.refunds IS 'Refund records with UUIDv7 for time-ordering';
