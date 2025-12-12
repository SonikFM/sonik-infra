-- Sonik OS: Events Table
-- Phase: 2 - Task 2.3
-- Date: 2025-12-08
-- Description: Ticketed events (concerts, festivals, shows)

CREATE TABLE finance.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization (FIRST-CLASS FK)
    organization_id UUID NOT NULL REFERENCES market.organizations(id),

    -- Event details
    name TEXT NOT NULL,
    slug TEXT,
    description TEXT,
    event_type TEXT CHECK (
        event_type IN ('concert', 'festival', 'conference', 'party', 'sports', 'theater', 'other')
    ),

    -- Location
    venue_name TEXT,
    venue_address TEXT,
    city TEXT,
    country_code TEXT REFERENCES shared.countries(code),

    -- Date & time
    event_date DATE NOT NULL,
    event_time TIME,
    doors_open_time TIME,
    timezone TEXT DEFAULT 'America/Bogota',

    -- Status
    status TEXT DEFAULT 'draft' CHECK (
        status IN ('draft', 'published', 'on_sale', 'sold_out', 'completed', 'cancelled', 'postponed')
    ),
    published_at TIMESTAMPTZ,

    -- Sales
    on_sale_at TIMESTAMPTZ,
    off_sale_at TIMESTAMPTZ,
    capacity INTEGER,
    tickets_sold INTEGER DEFAULT 0,

    -- External IDs
    directus_event_id TEXT,
    stripe_product_id TEXT,
    mercadopago_product_id TEXT,

    -- Media
    poster_url TEXT,
    cover_image_url TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_events_org ON finance.events(organization_id);
CREATE INDEX idx_events_slug ON finance.events(slug);
CREATE INDEX idx_events_status ON finance.events(status);
CREATE INDEX idx_events_date ON finance.events(event_date);
CREATE INDEX idx_events_city ON finance.events(city);
CREATE INDEX idx_events_country ON finance.events(country_code);

-- UNIQUE constraints on external IDs
CREATE UNIQUE INDEX idx_events_directus_unique
    ON finance.events(directus_event_id)
    WHERE directus_event_id IS NOT NULL;

CREATE UNIQUE INDEX idx_events_stripe_product_unique
    ON finance.events(stripe_product_id)
    WHERE stripe_product_id IS NOT NULL;

CREATE UNIQUE INDEX idx_events_mp_product_unique
    ON finance.events(mercadopago_product_id)
    WHERE mercadopago_product_id IS NOT NULL;

COMMENT ON TABLE finance.events IS 'Ticketed events with sales tracking';

-- Add updated_at trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON finance.events
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();
