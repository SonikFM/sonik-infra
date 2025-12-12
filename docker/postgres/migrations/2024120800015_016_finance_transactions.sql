-- Sonik OS: Transactions Table
-- Phase: 2 - Task 2.5
-- Date: 2025-12-08
-- Description: All ticket purchases with DETAILED fee breakdown and USD conversion
-- Updates: Addendum schema with tax_amount_cents, forex_fee_cents, customer FK, UUIDv7

CREATE TABLE finance.transactions (
    id UUID PRIMARY KEY DEFAULT uuidv7(),  -- Time-ordered for performance

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- What was bought
    event_id UUID REFERENCES finance.events(id),
    ticket_tier_id UUID REFERENCES finance.ticket_tiers(id),
    quantity INTEGER DEFAULT 1,

    -- Money (Native Currency)
    gross_amount_cents BIGINT NOT NULL,

    -- Fee Breakdown (detailed)
    platform_fee_cents BIGINT DEFAULT 0,      -- Sonik's platform fee
    processor_fee_cents BIGINT DEFAULT 0,     -- Stripe/MercadoPago fee
    tax_amount_cents BIGINT DEFAULT 0,        -- Government taxes (IVA, etc.)
    forex_fee_cents BIGINT DEFAULT 0,         -- Currency conversion fee

    net_amount_cents BIGINT NOT NULL,         -- Amount to organizer after all fees
    currency TEXT NOT NULL DEFAULT 'COP' REFERENCES shared.currencies(code),

    -- USD Conversion (for reporting)
    usd_amount_cents BIGINT,                  -- Converted amount in USD
    fx_rate_to_usd DECIMAL(18,8),             -- Exchange rate used
    fx_rate_date DATE,                        -- When rate was applied

    -- Payment
    processor_code TEXT REFERENCES finance.payment_processors(code),
    processor_transaction_id TEXT,            -- UNIQUE constraint added below

    -- Status
    status TEXT DEFAULT 'pending' CHECK (
        status IN ('pending', 'completed', 'failed', 'refunded', 'partially_refunded', 'disputed', 'cancelled')
    ),

    -- Buyer (with customer relationship)
    customer_id UUID REFERENCES market.customers(id),  -- NEW: Link to customer record
    buyer_user_id UUID REFERENCES shared.users(id),    -- Can be NULL for guest checkout

    -- Denormalized buyer fields (for guest checkout + fast access)
    buyer_email TEXT,
    buyer_name TEXT,
    buyer_phone TEXT,

    -- Attribution (Amplify + EventUTM integration)
    attribution_source TEXT,                  -- 'organic', 'meta', 'google', 'tiktok', 'referral'
    attribution_campaign TEXT,
    attribution_data JSONB,                   -- Full attribution chain
    event_utm_id UUID,                        -- Link to EventUTM (legacy attribution)

    -- Transaction metadata
    transaction_type TEXT DEFAULT 'purchase' CHECK (
        transaction_type IN ('purchase', 'refund', 'chargeback', 'adjustment')
    ),
    is_complimentary BOOLEAN DEFAULT FALSE,
    is_door_sale BOOLEAN DEFAULT FALSE,

    -- Timestamps
    transaction_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_transactions_org ON finance.transactions(organization_id);
CREATE INDEX idx_transactions_event ON finance.transactions(event_id);
CREATE INDEX idx_transactions_customer ON finance.transactions(customer_id);
CREATE INDEX idx_transactions_buyer ON finance.transactions(buyer_user_id);
CREATE INDEX idx_transactions_status ON finance.transactions(status);
CREATE INDEX idx_transactions_date ON finance.transactions(transaction_at);
CREATE INDEX idx_transactions_attribution ON finance.transactions(attribution_source);

-- UNIQUE constraint on processor_transaction_id (prevent duplicate external transactions)
CREATE UNIQUE INDEX idx_transactions_processor_txn_unique
    ON finance.transactions(processor_transaction_id)
    WHERE processor_transaction_id IS NOT NULL;

COMMENT ON TABLE finance.transactions IS 'All ticket purchases with full fee breakdown and USD conversion';
