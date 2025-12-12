# Schema Migrations - Final Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete Supabase schema updates for claim_status enum, canonical IDs, and events as first-class entity before PG18 migration.

**Architecture:** Events become first-class entity in `content.events` (non-financial), with `finance.events` referencing it via foreign key. Canonical IDs (google_places_id, instagram_url) added to market schema for ownership verification. claim_status migration already created.

**Tech Stack:** PostgreSQL, Supabase migrations, SQL

**Linear Issues:** SON-375 (Schema), SON-376 (PG18 - BLOCKING)

---

## Trade-Off Analysis: Events Schema

### Option A: Single Table (finance.events with discriminators)
**Pros:**
- Simpler queries (no JOINs)
- All event data in one place
- Existing schema already works

**Cons:**
- Mixes financial and non-financial concerns
- RSVP events don't belong in "finance" schema
- Discovery events have no financial data

### Option B: First-Class Events Entity (RECOMMENDED)
**Pros:**
- Clean separation: `content.events` (all events) → `finance.events` (ticketed only)
- RSVP/Discovery events don't pollute finance schema
- Events are truly first-class with their own lifecycle
- Finance.events becomes a "ticket configuration" that references content.events

**Cons:**
- Requires JOIN for ticketed event queries
- Migration of existing finance.events data

**Decision:** Option B - Events as first-class entity in `content` schema.

---

## Task 1: Verify claim_status Migration Exists

**Files:**
- Verify: `supabase/migrations/20241210001_claim_status_enum.sql`

**Step 1: Confirm migration file exists and is correct**

Run: `ls -la supabase/migrations/20241210001_claim_status_enum.sql`
Expected: File exists with ~253 lines

**Step 2: Validate SQL syntax**

Run: `head -30 supabase/migrations/20241210001_claim_status_enum.sql`
Expected: See claim_status_enum creation

---

## Task 2: Create Canonical IDs Migration

**Files:**
- Create: `supabase/migrations/20241210002_canonical_ids.sql`

**Step 1: Write the migration SQL**

```sql
-- Sonik OS: Canonical IDs Migration
-- Date: 2025-12-10
-- Description: Add google_places_id, instagram_url for ownership verification
-- Note: Google Place IDs can expire after 12+ months, track last_refreshed

-- Step 1: Add canonical ID columns to market.entities
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'market' AND table_name = 'entities'
    ) THEN
        -- Google Places ID (primary for venues)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'entities'
            AND column_name = 'google_places_id'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN google_places_id TEXT;
        END IF;

        -- Instagram URL (fallback canonical ID)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'entities'
            AND column_name = 'instagram_url'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN instagram_url TEXT;
        END IF;

        -- Track when canonical IDs were last verified/refreshed
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'entities'
            AND column_name = 'canonical_id_refreshed_at'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN canonical_id_refreshed_at TIMESTAMPTZ;
        END IF;

        -- Create partial unique indexes (only where not null)
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market' AND tablename = 'entities'
            AND indexname = 'idx_entities_google_places_unique'
        ) THEN
            CREATE UNIQUE INDEX idx_entities_google_places_unique
            ON market.entities(google_places_id)
            WHERE google_places_id IS NOT NULL;
        END IF;

        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market' AND tablename = 'entities'
            AND indexname = 'idx_entities_instagram_unique'
        ) THEN
            CREATE UNIQUE INDEX idx_entities_instagram_unique
            ON market.entities(instagram_url)
            WHERE instagram_url IS NOT NULL;
        END IF;
    END IF;
END $$;

-- Step 2: Add canonical ID columns to market.organizations
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'market' AND table_name = 'organizations'
    ) THEN
        -- Google Places ID
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'organizations'
            AND column_name = 'google_places_id'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN google_places_id TEXT;
        END IF;

        -- Instagram URL
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'organizations'
            AND column_name = 'instagram_url'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN instagram_url TEXT;
        END IF;

        -- Domain (primary for organizations - DNS TXT verification)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'organizations'
            AND column_name = 'domain'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN domain TEXT;
        END IF;

        -- LinkedIn URL (secondary for organizations)
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'organizations'
            AND column_name = 'linkedin_url'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN linkedin_url TEXT;
        END IF;

        -- Canonical ID refresh tracking
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market' AND table_name = 'organizations'
            AND column_name = 'canonical_id_refreshed_at'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN canonical_id_refreshed_at TIMESTAMPTZ;
        END IF;

        -- Create partial unique indexes
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market' AND tablename = 'organizations'
            AND indexname = 'idx_orgs_google_places_unique'
        ) THEN
            CREATE UNIQUE INDEX idx_orgs_google_places_unique
            ON market.organizations(google_places_id)
            WHERE google_places_id IS NOT NULL;
        END IF;

        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market' AND tablename = 'organizations'
            AND indexname = 'idx_orgs_instagram_unique'
        ) THEN
            CREATE UNIQUE INDEX idx_orgs_instagram_unique
            ON market.organizations(instagram_url)
            WHERE instagram_url IS NOT NULL;
        END IF;

        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market' AND tablename = 'organizations'
            AND indexname = 'idx_orgs_domain_unique'
        ) THEN
            CREATE UNIQUE INDEX idx_orgs_domain_unique
            ON market.organizations(domain)
            WHERE domain IS NOT NULL;
        END IF;
    END IF;
END $$;

-- Step 3: Add comments
COMMENT ON COLUMN market.entities.google_places_id IS 'Google Place ID for venue verification (expires after 12+ months, refresh regularly)';
COMMENT ON COLUMN market.entities.instagram_url IS 'Instagram profile URL for fallback verification';
COMMENT ON COLUMN market.entities.canonical_id_refreshed_at IS 'When canonical IDs were last verified/refreshed';

COMMENT ON COLUMN market.organizations.google_places_id IS 'Google Place ID for venue-type organizations';
COMMENT ON COLUMN market.organizations.instagram_url IS 'Instagram business URL for verification';
COMMENT ON COLUMN market.organizations.domain IS 'Organization domain for DNS TXT verification (primary for orgs)';
COMMENT ON COLUMN market.organizations.linkedin_url IS 'LinkedIn company page URL for verification';
COMMENT ON COLUMN market.organizations.canonical_id_refreshed_at IS 'When canonical IDs were last verified/refreshed';
```

**Step 2: Save the file**

Create file at: `supabase/migrations/20241210002_canonical_ids.sql`

**Step 3: Commit**

```bash
git add supabase/migrations/20241210002_canonical_ids.sql
git commit -m "feat(schema): add canonical IDs for ownership verification

- Add google_places_id, instagram_url to market.entities
- Add google_places_id, instagram_url, domain, linkedin_url to market.organizations
- Add canonical_id_refreshed_at for tracking refresh (Google IDs expire)
- Create partial unique indexes for deduplication

Part of SON-375"
```

---

## Task 3: Create Content Schema and Events Table

**Files:**
- Create: `supabase/migrations/20241210003_content_events.sql`

**Step 1: Write the migration SQL**

```sql
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
    organization_id UUID REFERENCES market.organizations(id),
    creator_user_id UUID REFERENCES shared.users(id),

    -- Claim status (for discovery events that get claimed)
    claim_status claim_status_enum DEFAULT 'unclaimed',
    claimed_at TIMESTAMPTZ,
    claimed_by UUID REFERENCES shared.users(id),

    -- Discovery event metadata
    scraped_source TEXT, -- 'facebook', 'instagram', 'bandsintown', 'resident_advisor', etc.
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
    parent_event_id UUID REFERENCES content.events(id),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    published_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT event_has_owner CHECK (
        -- Discovery events don't need owner
        (event_category = 'discovery') OR
        -- Non-discovery events need either org or user
        (organization_id IS NOT NULL OR creator_user_id IS NOT NULL)
    ),
    CONSTRAINT ticketed_requires_org CHECK (
        -- Ticketed events MUST have organization (not individual)
        (is_ticketed = FALSE) OR
        (is_ticketed = TRUE AND organization_id IS NOT NULL)
    ),
    CONSTRAINT unique_external_event UNIQUE (scraped_source, external_event_id)
);

-- Step 6: Create indexes
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

-- Step 7: Add updated_at trigger
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

-- Step 8: Add comments
COMMENT ON TABLE content.events IS 'First-class events entity. All events live here; finance.events references this for ticketed events.';
COMMENT ON COLUMN content.events.event_category IS 'Event type: ticketed_public, ticketed_private, non_ticketed_private, discovery';
COMMENT ON COLUMN content.events.is_ticketed IS 'Generated: TRUE for ticketed_public and ticketed_private';
COMMENT ON COLUMN content.events.requires_invite IS 'Generated: TRUE for ticketed_private and non_ticketed_private';
COMMENT ON COLUMN content.events.organization_id IS 'Organizer organization. Required for ticketed events.';
COMMENT ON COLUMN content.events.creator_user_id IS 'Individual creator (for RSVP events without organization)';
COMMENT ON COLUMN content.events.scraped_source IS 'Source platform for discovery events (facebook, instagram, etc.)';
COMMENT ON COLUMN content.events.series_id IS 'Groups recurring events into series';
```

**Step 2: Save the file**

Create file at: `supabase/migrations/20241210003_content_events.sql`

**Step 3: Commit**

```bash
git add supabase/migrations/20241210003_content_events.sql
git commit -m "feat(schema): create content.events as first-class entity

- Create content schema
- Create event_category, event_visibility, event_status enums
- Create content.events with 4 event types support
- Add generated columns for is_ticketed, requires_invite
- Add constraints: ticketed requires org, discovery doesn't need owner
- Add discovery event fields (scraped_source, external_url)
- Add RSVP tracking for non-ticketed events
- Add series support for recurring events

Part of SON-375"
```

---

## Task 4: Add Foreign Key from finance.events to content.events

**Files:**
- Create: `supabase/migrations/20241210004_finance_events_fk.sql`

**Step 1: Write the migration SQL**

```sql
-- Sonik OS: Finance Events Foreign Key Migration
-- Date: 2025-12-10
-- Description: Link finance.events to content.events (ticketed event configurations)

-- Step 1: Add content_event_id to finance.events
DO $$
BEGIN
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'finance' AND table_name = 'events'
    ) THEN
        -- Add foreign key column if not exists
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'finance' AND table_name = 'events'
            AND column_name = 'content_event_id'
        ) THEN
            ALTER TABLE finance.events
            ADD COLUMN content_event_id UUID REFERENCES content.events(id);
        END IF;

        -- Create index for the foreign key
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'finance' AND tablename = 'events'
            AND indexname = 'idx_finance_events_content_event'
        ) THEN
            CREATE INDEX idx_finance_events_content_event
            ON finance.events(content_event_id)
            WHERE content_event_id IS NOT NULL;
        END IF;
    END IF;
END $$;

-- Step 2: Add comment
COMMENT ON COLUMN finance.events.content_event_id IS 'Reference to content.events - the first-class event entity. Finance.events stores ticketing configuration.';
```

**Step 2: Save the file**

Create file at: `supabase/migrations/20241210004_finance_events_fk.sql`

**Step 3: Commit**

```bash
git add supabase/migrations/20241210004_finance_events_fk.sql
git commit -m "feat(schema): link finance.events to content.events

- Add content_event_id FK to finance.events
- Finance.events now stores ticketing config for content.events
- Events are first-class in content schema

Part of SON-375"
```

---

## Task 5: Update Schema Documentation

**Files:**
- Modify: `docs/schemas/UNIFIED-SCHEMA-REFERENCE.md`

**Step 1: Add content.events section to documentation**

Add new section for content schema with events table definition.

**Step 2: Update market.entities section with canonical ID columns**

Add google_places_id, instagram_url, canonical_id_refreshed_at.

**Step 3: Update market.organizations section**

Add google_places_id, instagram_url, domain, linkedin_url, canonical_id_refreshed_at.

**Step 4: Commit**

```bash
git add docs/schemas/UNIFIED-SCHEMA-REFERENCE.md
git commit -m "docs(schema): update reference with content.events and canonical IDs"
```

---

## Task 6: Update Linear Issue and Record Decisions

**Step 1: Add comment to SON-375 with migration summary**

Content:
```
## Schema Updates Implemented (Dec 10)

### Migration 001: claim_status enum
- Changed is_claimed boolean to claim_status enum
- Values: unclaimed, pending, claimed, restricted, banned
- Added claim workflow metadata fields

### Migration 002: Canonical IDs
- Added google_places_id, instagram_url to market.entities
- Added google_places_id, instagram_url, domain, linkedin_url to market.organizations
- Added canonical_id_refreshed_at for Google ID refresh tracking
- Created partial unique indexes

### Migration 003: content.events (First-Class Entity)
- Created content schema
- Created content.events as first-class entity
- 4 event types: ticketed_public, ticketed_private, non_ticketed_private, discovery
- Generated columns: is_ticketed, requires_invite
- Constraints: ticketed requires org, discovery doesn't need owner

### Migration 004: finance.events FK
- Added content_event_id FK to finance.events
- Finance.events now stores ticketing config referencing content.events

### Research Completed
- Event architecture patterns: docs/research/event-architecture-patterns.md
- Canonical ID best practices: docs/research/canonical-id-best-practices.md
```

**Step 2: Update brainstorm-decisions.md with final decisions**

---

## Summary

| Migration | Description | Status |
|-----------|-------------|--------|
| 20241210001 | claim_status enum | ✅ Created |
| 20241210002 | Canonical IDs | To create |
| 20241210003 | content.events | To create |
| 20241210004 | finance.events FK | To create |

**Total Tasks:** 6
**Estimated Time:** 30-45 minutes

---

## Files Created This Plan

- `supabase/migrations/20241210001_claim_status_enum.sql` (already exists)
- `supabase/migrations/20241210002_canonical_ids.sql`
- `supabase/migrations/20241210003_content_events.sql`
- `supabase/migrations/20241210004_finance_events_fk.sql`
- `docs/schemas/UNIFIED-SCHEMA-REFERENCE.md` (update)
