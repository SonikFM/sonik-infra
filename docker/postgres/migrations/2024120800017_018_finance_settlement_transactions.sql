-- Sonik OS: Settlement Transactions Table
-- Phase: 2 - Task 2.7
-- Date: 2025-12-08
-- Description: Line items within settlement batches (with UUIDv7)
-- Updates: Addendum schema with UUIDv7 for time-ordering

CREATE TABLE finance.settlement_transactions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),  -- Changed from gen_random_uuid()

    -- References
    batch_id UUID NOT NULL REFERENCES finance.settlement_batches(id) ON DELETE CASCADE,
    transaction_id UUID NOT NULL REFERENCES finance.transactions(id),

    -- Amounts at settlement time
    gross_amount_cents BIGINT NOT NULL,
    fees_cents BIGINT DEFAULT 0,
    net_amount_cents BIGINT NOT NULL,

    -- Type
    line_type TEXT DEFAULT 'sale' CHECK (
        line_type IN ('sale', 'refund', 'chargeback', 'adjustment', 'fee')
    ),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_settlement_txns_batch ON finance.settlement_transactions(batch_id);
CREATE INDEX idx_settlement_txns_txn ON finance.settlement_transactions(transaction_id);

COMMENT ON TABLE finance.settlement_transactions IS 'Settlement batch line items with UUIDv7';
