-- Sonik OS: Settlement Batches Table
-- Phase: 2 - Task 2.6
-- Date: 2025-12-08
-- Description: Groups of transactions settled together per organization

CREATE TABLE finance.settlement_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Period
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,

    -- Amounts (native currency)
    gross_amount_cents BIGINT NOT NULL,
    fees_cents BIGINT DEFAULT 0,
    adjustments_cents BIGINT DEFAULT 0,
    net_amount_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- USD conversion
    usd_amount_cents BIGINT,
    fx_rate_to_usd DECIMAL(18,8),

    -- Stats
    transaction_count INTEGER DEFAULT 0,
    refund_count INTEGER DEFAULT 0,

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'completed', 'failed')
    ),

    -- Processor
    processor_code TEXT REFERENCES finance.payment_processors(code),
    processor_batch_id TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_settlement_batches_org ON finance.settlement_batches(organization_id);
CREATE INDEX idx_settlement_batches_period ON finance.settlement_batches(period_start, period_end);
CREATE INDEX idx_settlement_batches_status ON finance.settlement_batches(status);
CREATE INDEX idx_settlement_batches_processor ON finance.settlement_batches(processor_code);

COMMENT ON TABLE finance.settlement_batches IS 'Grouped settlements per organization';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.settlement_batches
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
