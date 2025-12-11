-- Sonik OS: Foreign Exchange Rates Table
-- Phase: 2 - Task 2.11
-- Date: 2025-12-08
-- Description: Daily FX rates for USD conversion and reporting

CREATE TABLE finance.fx_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Currency pair
    from_currency TEXT NOT NULL REFERENCES shared.currencies(code),
    to_currency TEXT NOT NULL REFERENCES shared.currencies(code),

    -- Rate
    rate DECIMAL(18,8) NOT NULL,
    rate_date DATE NOT NULL DEFAULT CURRENT_DATE,

    -- Source
    source TEXT DEFAULT 'manual' CHECK (
        source IN ('manual', 'api', 'banco_republica', 'xe', 'openexchangerates')
    ),
    source_metadata JSONB,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(from_currency, to_currency, rate_date)
);

-- Indexes
CREATE INDEX idx_fx_rates_pair ON finance.fx_rates(from_currency, to_currency);
CREATE INDEX idx_fx_rates_date ON finance.fx_rates(rate_date DESC);
CREATE INDEX idx_fx_rates_source ON finance.fx_rates(source);

COMMENT ON TABLE finance.fx_rates IS 'Daily foreign exchange rates for multi-currency reporting';

-- Seed initial USD conversion rates (December 2025 approximate)
INSERT INTO finance.fx_rates (from_currency, to_currency, rate, rate_date, source) VALUES
    ('COP', 'USD', 0.00025, CURRENT_DATE, 'manual'),  -- 1 COP = 0.00025 USD (4000 COP = 1 USD)
    ('USD', 'COP', 4000.00, CURRENT_DATE, 'manual'),  -- 1 USD = 4000 COP
    ('MXN', 'USD', 0.05, CURRENT_DATE, 'manual'),     -- 1 MXN = 0.05 USD (20 MXN = 1 USD)
    ('USD', 'MXN', 20.00, CURRENT_DATE, 'manual'),    -- 1 USD = 20 MXN
    ('EUR', 'USD', 1.10, CURRENT_DATE, 'manual'),     -- 1 EUR = 1.10 USD
    ('USD', 'EUR', 0.91, CURRENT_DATE, 'manual');     -- 1 USD = 0.91 EUR

-- Verify
SELECT from_currency, to_currency, rate, rate_date FROM finance.fx_rates ORDER BY from_currency, to_currency;
