-- Sonik OS: Updated Timestamp Triggers
-- Phase: 1 - Task 1.10
-- Date: 2025-12-08
-- Description: Automatic updated_at timestamp maintenance for all tables

-- Create trigger function
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION trigger_set_updated_at() IS 'Automatically update updated_at timestamp on row changes';

-- Apply to all Phase 1 tables with updated_at column
CREATE TRIGGER set_updated_at BEFORE UPDATE ON shared.users
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON market.organizations
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON market.customers
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON market.organization_members
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

-- Verify triggers were created
SELECT
    trigger_schema,
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_name = 'set_updated_at'
ORDER BY trigger_schema, event_object_table;
