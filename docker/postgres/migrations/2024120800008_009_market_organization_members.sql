-- Sonik OS: Organization Members Table
-- Phase: 1 - Task 1.8
-- Date: 2025-12-08
-- Description: Role-based organization membership (owners, staff, collaborators)

CREATE TABLE market.organization_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Relationships
    organization_id UUID NOT NULL REFERENCES market.organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES shared.users(id) ON DELETE CASCADE,

    -- Role
    role TEXT NOT NULL CHECK (
        role IN ('owner', 'admin', 'staff', 'collaborator', 'viewer')
    ),

    -- Permissions
    permissions JSONB DEFAULT '{}',

    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    invited_by UUID REFERENCES shared.users(id),
    invited_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(organization_id, user_id)  -- One membership record per user-org pair
);

-- Indexes
CREATE INDEX idx_org_members_org ON market.organization_members(organization_id);
CREATE INDEX idx_org_members_user ON market.organization_members(user_id);
CREATE INDEX idx_org_members_role ON market.organization_members(role);
CREATE INDEX idx_org_members_status ON market.organization_members(status);

COMMENT ON TABLE market.organization_members IS 'Role-based organization membership';
