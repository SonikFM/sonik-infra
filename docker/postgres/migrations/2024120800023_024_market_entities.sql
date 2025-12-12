-- Sonik OS: Entities Table
-- Phase: 3 - Task 3.1
-- Date: 2025-12-08
-- Description: Non-org market participants (artists, influencers, content accounts, sponsors, venues)
-- Schema: Aligned with Twenty CRM V2 and Directus V2 schemas

CREATE TABLE market.entities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    name TEXT NOT NULL,
    slug TEXT UNIQUE,
    entity_type TEXT NOT NULL CHECK (
        entity_type IN ('artist', 'influencer', 'content_account', 'sponsor', 'venue', 'media', 'other')
    ),

    -- Bio/Description
    bio TEXT,
    bio_short TEXT,                    -- One-line description

    -- Media
    profile_image_url TEXT,
    cover_image_url TEXT,

    -- Location
    city TEXT,
    region TEXT,
    country_code TEXT REFERENCES shared.countries(code),

    -- Social Media (from Directus influencers)
    instagram_handle TEXT,
    instagram_url TEXT,

    tiktok_handle TEXT,
    tiktok_url TEXT,

    twitter_handle TEXT,
    twitter_url TEXT,

    youtube_handle TEXT,
    youtube_url TEXT,

    facebook_url TEXT,

    spotify_url TEXT,
    soundcloud_url TEXT,
    apple_music_url TEXT,

    -- Primary Platform (for influencers/content accounts)
    primary_platform TEXT CHECK (
        primary_platform IS NULL
        OR primary_platform IN ('instagram', 'tiktok', 'youtube', 'twitter', 'facebook', 'spotify')
    ),

    -- Website & Contact
    website_url TEXT,
    contact_email TEXT,
    booking_email TEXT,

    -- Classification
    genres JSONB,                      -- Music genres for artists
    categories JSONB,                  -- Content categories for influencers/accounts
    topics JSONB,                      -- Topics covered (for content accounts)
    tags TEXT[],                       -- Flexible tagging

    -- Audience/Reach (from Twenty Person & Directus content_accounts)
    audience_size_tier TEXT CHECK (
        audience_size_tier IS NULL
        OR audience_size_tier IN ('nano', 'micro', 'mid', 'macro', 'mega')
    ),
    follower_count INTEGER,            -- From Twenty Person / Directus content_accounts
    engagement_rate DECIMAL(5,2),      -- From Directus content_accounts

    -- Business Info
    management_info TEXT,              -- From Directus artists (management_info)
    rate_per_post_cents INTEGER,       -- From Twenty Person (rate_per_post)
    typical_deal_size_cents INTEGER,   -- Typical campaign budget

    -- Relationship Status (from Twenty Person)
    relationship_status TEXT DEFAULT 'prospect' CHECK (
        relationship_status IN ('prospect', 'outreach', 'negotiation', 'active', 'paused', 'inactive')
    ),
    relationship_quality TEXT CHECK (
        relationship_quality IS NULL
        OR relationship_quality IN ('excellent', 'good', 'fair', 'poor')
    ),

    -- Partnership Flags
    has_sonik_partnership BOOLEAN DEFAULT FALSE,
    partnership_type TEXT CHECK (
        partnership_type IS NULL
        OR partnership_type IN ('paid_posts', 'affiliate', 'content_share', 'sponsored', 'organic', 'performance')
    ),

    -- Performance Tracking (from Twenty Person)
    lifetime_value_cents BIGINT DEFAULT 0,  -- From Twenty Person.lifetime_value
    last_campaign_date DATE,                -- From Twenty Person.last_campaign_date
    last_interaction_date DATE,

    -- External System IDs
    twenty_crm_id TEXT,                -- Link to Twenty CRM Person
    directus_id TEXT,                  -- Link to Directus (artists/influencers/content_accounts)
    spotify_artist_id TEXT,
    instagram_business_id TEXT,

    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    is_claimed BOOLEAN DEFAULT FALSE,  -- Has entity claimed their profile?
    claim_email TEXT,
    verified_at TIMESTAMPTZ,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'archived')),

    -- Vector Embedding (Qwen 3)
    embedding VECTOR(1024),            -- Using Qwen3-Embedding-0.6B (1024D)
                                       -- NOTE: Use VECTOR(4096) for Qwen3-Embedding-8B

    -- Metadata
    metadata JSONB DEFAULT '{}',       -- Flexible additional data

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Standard Indexes
CREATE INDEX idx_entities_type ON market.entities(entity_type);
CREATE INDEX idx_entities_slug ON market.entities(slug);
CREATE INDEX idx_entities_relationship ON market.entities(relationship_status);
CREATE INDEX idx_entities_partnership ON market.entities(has_sonik_partnership) WHERE has_sonik_partnership = TRUE;
CREATE INDEX idx_entities_instagram ON market.entities(instagram_handle) WHERE instagram_handle IS NOT NULL;
CREATE INDEX idx_entities_tiktok ON market.entities(tiktok_handle) WHERE tiktok_handle IS NOT NULL;
CREATE INDEX idx_entities_city ON market.entities(city);
CREATE INDEX idx_entities_country ON market.entities(country_code);

-- Vector similarity search index (HNSW for fast approximate nearest neighbor)
CREATE INDEX idx_entities_embedding ON market.entities
    USING hnsw (embedding vector_cosine_ops);

-- External ID unique constraints
CREATE UNIQUE INDEX idx_entities_twenty_unique
    ON market.entities(twenty_crm_id)
    WHERE twenty_crm_id IS NOT NULL;

CREATE UNIQUE INDEX idx_entities_directus_unique
    ON market.entities(directus_id)
    WHERE directus_id IS NOT NULL;

CREATE UNIQUE INDEX idx_entities_spotify_unique
    ON market.entities(spotify_artist_id)
    WHERE spotify_artist_id IS NOT NULL;

-- Updated timestamp trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON market.entities
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

COMMENT ON TABLE market.entities IS 'Non-org market participants: artists, influencers, content accounts, sponsors, venues';
COMMENT ON COLUMN market.entities.embedding IS 'Qwen 3 embedding (1024D for 0.6B model, 4096D for 8B model)';
