-- Sonik OS: Content Events Migration
-- Date: 2025-12-10
-- Description: Create content.events as first-class entity
-- Events are the core of the platform; finance.events references this for ticketed events

-- Step 1: Create content schema if not exists
CREATE SCHEMA IF NOT EXISTS content;

-- Step 2: Create event_category enum
DO $$ BEGIN
    CREATE TYPE event_category_enum AS ENUM (
        'ticketed_public',
        'ticketed_private',
        'non_ticketed_private',
        'discovery'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 3: Create event_visibility enum
DO $$ BEGIN
    CREATE TYPE event_visibility_enum AS ENUM (
        'public',
        'invite_only',
        'hidden'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 4: Create event_status enum
DO $$ BEGIN
    CREATE TYPE event_status_enum AS ENUM (
        'draft',
        'discovered',
        'published',
        'on_sale',
        'sold_out',
        'completed',
        'cancelled',
        'postponed',
        'archived'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 5: Create content.events table (first-class entity)
CREATE TABLE IF NOT EXISTS content.events (
    -- Primary key (UUIDv7 for time-ordering)
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Event type classification
    event_category event_category_enum NOT NULL DEFAULT 'discovery',
    visibility event_visibility_enum NOT NULL DEFAULT 'public',
    status event_status_enum NOT NULL DEFAULT 'draft',

    -- Generated helper columns
    is_ticketed BOOLEAN GENERATED ALWAYS AS (event_category IN ('ticketed_public', 'ticketed_private')) STORED,
    requires_invite BOOLEAN GENERATED ALWAYS AS (event_category IN ('ticketed_private', 'non_ticketed_private')) STORED,

    -- Core event info
    name TEXT NOT NULL,
    slug TEXT,
    description TEXT,

    -- Date/time
    event_date DATE NOT NULL,
    event_time TIME,
    end_date DATE,
    end_time TIME,
    timezone TEXT DEFAULT 'America/Bogota',

    -- Location (string fields, can link to market.entities later)
    venue_name TEXT,
    venue_address TEXT,
    city TEXT,
    country_code TEXT DEFAULT 'CO',
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),

    -- Ownership - organization OR user (mutually exclusive for non-discovery)
    organization_id UUID,
    creator_user_id UUID,

    -- Claim status (for discovery events that get claimed)
    claim_status claim_status_enum DEFAULT 'unclaimed',
    claimed_at TIMESTAMPTZ,
    claimed_by UUID,

    -- Discovery event metadata
    scraped_source TEXT,
    external_url TEXT,
    external_event_id TEXT,
    scraped_at TIMESTAMPTZ,

    -- RSVP tracking (for non-ticketed events)
    rsvp_count INTEGER DEFAULT 0,
    rsvp_limit INTEGER,

    -- Media
    poster_url TEXT,
    cover_image_url TEXT,

    -- Capacity (for all event types)
    capacity INTEGER,

    -- Series/recurring support
    series_id UUID,
    parent_event_id UUID,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT event_has_owner CHECK (
        (event_category = 'discovery') OR
        (organization_id IS NOT NULL OR creator_user_id IS NOT NULL)
    ),
    CONSTRAINT ticketed_requires_org CHECK (
        (is_ticketed = FALSE) OR
        (is_ticketed = TRUE AND organization_id IS NOT NULL)
    ),
    CONSTRAINT unique_external_event UNIQUE (scraped_source, external_event_id)
);

-- Step 6: Add foreign key for parent_event_id (self-referencing)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'events_parent_event_fk'
    ) THEN
        ALTER TABLE content.events
        ADD CONSTRAINT events_parent_event_fk
        FOREIGN KEY (parent_event_id) REFERENCES content.events(id);
    END IF;
END $$;

-- Step 7: Create indexes
CREATE INDEX IF NOT EXISTS idx_content_events_category ON content.events(event_category);
CREATE INDEX IF NOT EXISTS idx_content_events_status ON content.events(status);
CREATE INDEX IF NOT EXISTS idx_content_events_visibility ON content.events(visibility);
CREATE INDEX IF NOT EXISTS idx_content_events_date ON content.events(event_date);
CREATE INDEX IF NOT EXISTS idx_content_events_org ON content.events(organization_id) WHERE organization_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_content_events_creator ON content.events(creator_user_id) WHERE creator_user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_content_events_city ON content.events(city);
CREATE INDEX IF NOT EXISTS idx_content_events_scraped ON content.events(scraped_source) WHERE scraped_source IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_content_events_series ON content.events(series_id) WHERE series_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_content_events_slug ON content.events(slug) WHERE slug IS NOT NULL;

-- Step 8: Add updated_at trigger
CREATE OR REPLACE FUNCTION content.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS events_updated_at ON content.events;
CREATE TRIGGER events_updated_at
    BEFORE UPDATE ON content.events
    FOR EACH ROW
    EXECUTE FUNCTION content.update_updated_at();

-- Step 9: Add comments
COMMENT ON TABLE content.events IS 'First-class events entity. All events live here; finance.events references this for ticketed events.';
COMMENT ON COLUMN content.events.event_category IS 'Event type: ticketed_public, ticketed_private, non_ticketed_private, discovery';
COMMENT ON COLUMN content.events.is_ticketed IS 'Generated: TRUE for ticketed_public and ticketed_private';
COMMENT ON COLUMN content.events.requires_invite IS 'Generated: TRUE for ticketed_private and non_ticketed_private';
COMMENT ON COLUMN content.events.organization_id IS 'Organizer organization. Required for ticketed events.';
COMMENT ON COLUMN content.events.creator_user_id IS 'Individual creator (for RSVP events without organization)';
COMMENT ON COLUMN content.events.scraped_source IS 'Source platform for discovery events (facebook, instagram, etc.)';
COMMENT ON COLUMN content.events.series_id IS 'Groups recurring events into series';
