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
