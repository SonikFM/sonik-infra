-- Sonik OS: Payment Processors Table
-- Phase: 2 - Task 2.1
-- Date: 2025-12-08
-- Description: Supported payment processors (Stripe, MercadoPago, etc.)

CREATE TABLE finance.payment_processors (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    supported_countries TEXT[],
    supported_currencies TEXT[],
    fee_structure JSONB,
    is_active BOOLEAN DEFAULT TRUE,
    api_version TEXT,
    config JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_processors_active ON finance.payment_processors(is_active);

COMMENT ON TABLE finance.payment_processors IS 'Supported payment processor configurations';

-- Seed initial processors
INSERT INTO finance.payment_processors (code, name, supported_countries, supported_currencies, is_active) VALUES
    ('stripe', 'Stripe', ARRAY['CO', 'US', 'MX'], ARRAY['COP', 'USD', 'MXN'], TRUE),
    ('mercadopago', 'MercadoPago', ARRAY['CO', 'MX'], ARRAY['COP', 'MXN'], TRUE),
    ('cash', 'Cash (Door Sales)', ARRAY['CO', 'US', 'MX'], ARRAY['COP', 'USD', 'MXN'], TRUE);

-- Verify
SELECT code, name, is_active FROM finance.payment_processors ORDER BY code;
