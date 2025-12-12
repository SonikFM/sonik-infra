-- Sonik OS: Reconciliation Reports Table
-- Phase: 2 - Task 2.12
-- Date: 2025-12-08
-- Description: Daily reconciliation between Supabase and payment processors

CREATE TABLE finance.reconciliation_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Report details
    report_date DATE NOT NULL DEFAULT CURRENT_DATE,
    report_type TEXT NOT NULL CHECK (
        report_type IN ('daily', 'weekly', 'monthly', 'event', 'ad_hoc')
    ),

    -- Processor
    processor_code TEXT REFERENCES finance.payment_processors(code),

    -- Counts
    supabase_transaction_count INTEGER,
    processor_transaction_count INTEGER,
    matched_count INTEGER,
    unmatched_count INTEGER,

    -- Amounts (native currency)
    supabase_total_cents BIGINT,
    processor_total_cents BIGINT,
    difference_cents BIGINT,
    currency TEXT DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'reconciled', 'discrepancy', 'investigating')
    ),

    -- Details
    discrepancies JSONB,
    notes TEXT,

    -- Resolution
    resolved_at TIMESTAMPTZ,
    resolved_by UUID REFERENCES shared.users(id),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_recon_reports_org ON finance.reconciliation_reports(organization_id);
CREATE INDEX idx_recon_reports_date ON finance.reconciliation_reports(report_date DESC);
CREATE INDEX idx_recon_reports_processor ON finance.reconciliation_reports(processor_code);
CREATE INDEX idx_recon_reports_status ON finance.reconciliation_reports(status);

-- UNIQUE constraint to prevent duplicate reports
CREATE UNIQUE INDEX idx_recon_reports_unique
    ON finance.reconciliation_reports(organization_id, report_date, processor_code, report_type);

COMMENT ON TABLE finance.reconciliation_reports IS 'Daily reconciliation between Supabase and payment processors';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.reconciliation_reports
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
