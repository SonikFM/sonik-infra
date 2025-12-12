-- Sonik OS: Entity Relationships Table
-- Phase: 3 - Task 3.2
-- Date: 2025-12-08
-- Description: Links entities to organizations and events (many-to-many)

CREATE TABLE market.entity_relationships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- References
    entity_id UUID NOT NULL REFERENCES market.entities(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES market.organizations(id) ON DELETE CASCADE,
    event_id UUID REFERENCES finance.events(id) ON DELETE CASCADE,

    -- Relationship Type
    relationship_type TEXT NOT NULL CHECK (
        relationship_type IN (
            'performer',        -- Artist performing at event
            'headliner',        -- Main act
            'supporting',       -- Supporting act
            'promoter',         -- Influencer promoting event
            'sponsor',          -- Brand sponsoring
            'venue_owner',      -- Venue entity
            'content_partner',  -- Content amplification
            'affiliate',        -- Affiliate marketing
            'other'
        )
    ),

    -- Deal Terms (if applicable)
    deal_value_cents INTEGER,
    currency TEXT REFERENCES shared.currencies(code),
    deal_terms TEXT,

    -- Performance (if tracked)
    impressions INTEGER,
    clicks INTEGER,
    conversions INTEGER,
    revenue_driven_cents BIGINT,

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('proposed', 'negotiating', 'confirmed', 'active', 'completed', 'cancelled')),

    -- Timestamps
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_entity_rels_entity ON market.entity_relationships(entity_id);
CREATE INDEX idx_entity_rels_org ON market.entity_relationships(organization_id);
CREATE INDEX idx_entity_rels_event ON market.entity_relationships(event_id);
CREATE INDEX idx_entity_rels_type ON market.entity_relationships(relationship_type);

-- Updated timestamp trigger
CREATE TRIGGER set_updated_at BEFORE UPDATE ON market.entity_relationships
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

COMMENT ON TABLE market.entity_relationships IS 'Links entities to organizations and events';
