-- Sonik OS: Payouts Table
-- Phase: 2 - Task 2.8
-- Date: 2025-12-08
-- Description: Actual money transfers to organizers

CREATE TABLE finance.payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Settlement batch (optional - some payouts may be ad-hoc)
    batch_id UUID REFERENCES finance.settlement_batches(id),

    -- Amounts (native currency)
    amount_cents BIGINT NOT NULL,
    currency TEXT NOT NULL DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- USD conversion
    usd_amount_cents BIGINT,
    fx_rate_to_usd DECIMAL(18,8),

    -- Destination
    payout_method TEXT CHECK (
        payout_method IN ('bank_transfer', 'stripe_payout', 'mercadopago_payout', 'check', 'other')
    ),
    bank_account_info JSONB,

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')
    ),

    -- Processor
    processor_code TEXT REFERENCES finance.payment_processors(code),
    processor_payout_id TEXT,

    -- Failure details
    failure_reason TEXT,
    failure_details JSONB,

    -- Timestamps
    scheduled_at DATE,
    initiated_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_payouts_org ON finance.payouts(organization_id);
CREATE INDEX idx_payouts_batch ON finance.payouts(batch_id);
CREATE INDEX idx_payouts_status ON finance.payouts(status);
CREATE INDEX idx_payouts_scheduled ON finance.payouts(scheduled_at);
CREATE INDEX idx_payouts_processor ON finance.payouts(processor_code);

COMMENT ON TABLE finance.payouts IS 'Money transfers to organizers';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.payouts
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
