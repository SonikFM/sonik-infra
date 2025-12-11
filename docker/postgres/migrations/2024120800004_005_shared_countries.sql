-- Sonik OS: Countries Table
-- Phase: 1 - Task 1.6
-- Date: 2025-12-08
-- Description: Country reference table with seed data for location tracking

CREATE TABLE shared.countries (
    code TEXT PRIMARY KEY CHECK (length(code) = 2),
    name TEXT NOT NULL,
    region TEXT,
    currency_code TEXT REFERENCES shared.currencies(code),
    phone_prefix TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_countries_region ON shared.countries(region);
CREATE INDEX idx_countries_currency ON shared.countries(currency_code);

COMMENT ON TABLE shared.countries IS 'Country reference table for location and localization';

-- Seed initial countries (Latin America focus)
INSERT INTO shared.countries (code, name, region, currency_code, phone_prefix) VALUES
    ('CO', 'Colombia', 'South America', 'COP', '+57'),
    ('US', 'United States', 'North America', 'USD', '+1'),
    ('MX', 'Mexico', 'North America', 'MXN', '+52');

-- Verify
SELECT * FROM shared.countries ORDER BY code;
