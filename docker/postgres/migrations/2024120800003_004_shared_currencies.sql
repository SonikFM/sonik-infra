-- Sonik OS: Currencies Table
-- Phase: 1 - Task 1.5
-- Date: 2025-12-08
-- Description: Currency reference table with seed data for multi-currency support

CREATE TABLE shared.currencies (
    code TEXT PRIMARY KEY CHECK (length(code) = 3),
    name TEXT NOT NULL,
    symbol TEXT NOT NULL,
    decimal_places INTEGER DEFAULT 2,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_currencies_active ON shared.currencies(is_active);

COMMENT ON TABLE shared.currencies IS 'Currency reference table for multi-currency support';

-- Seed initial currencies
INSERT INTO shared.currencies (code, name, symbol, decimal_places) VALUES
    ('COP', 'Colombian Peso', '$', 0),
    ('USD', 'US Dollar', '$', 2),
    ('EUR', 'Euro', '€', 2),
    ('MXN', 'Mexican Peso', '$', 2);

-- Verify
SELECT * FROM shared.currencies ORDER BY code;
