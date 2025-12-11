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
