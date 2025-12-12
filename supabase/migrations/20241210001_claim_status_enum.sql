-- Sonik OS: Claim Status Enum Migration
-- Date: 2025-12-10
-- Description: Migrate is_claimed boolean to claim_status enum with workflow metadata

-- Step 1: Create claim_status enum type
DO $$ BEGIN
    CREATE TYPE claim_status_enum AS ENUM (
        'unclaimed',
        'pending',
        'claimed',
        'restricted',
        'banned'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 2: Create claim_verification_method enum type
DO $$ BEGIN
    CREATE TYPE claim_verification_method_enum AS ENUM (
        'instagram_dm',
        'email',
        'phone',
        'manual',
        'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Step 3: Migrate market.entities table
DO $$
BEGIN
    -- Check if market.entities table exists
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'market'
        AND table_name = 'entities'
    ) THEN

        -- Add new claim_status column with default
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'claim_status'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN claim_status claim_status_enum DEFAULT 'unclaimed';
        END IF;

        -- Add claim workflow metadata columns
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'claim_requested_at'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN claim_requested_at TIMESTAMPTZ;
        END IF;

        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'claim_requested_by'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN claim_requested_by UUID REFERENCES shared.users(id);
        END IF;

        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'claim_verification_method'
        ) THEN
            ALTER TABLE market.entities
            ADD COLUMN claim_verification_method claim_verification_method_enum;
        END IF;

        -- Rename verified_at to claim_verified_at for clarity
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'verified_at'
        ) AND NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'claim_verified_at'
        ) THEN
            ALTER TABLE market.entities
            RENAME COLUMN verified_at TO claim_verified_at;
        END IF;

        -- Migrate existing data from is_claimed to claim_status
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'entities'
            AND column_name = 'is_claimed'
        ) THEN
            UPDATE market.entities
            SET claim_status = CASE
                WHEN is_claimed = TRUE THEN 'claimed'::claim_status_enum
                ELSE 'unclaimed'::claim_status_enum
            END
            WHERE claim_status = 'unclaimed'::claim_status_enum; -- Only update if still at default

            -- Drop the old is_claimed column
            ALTER TABLE market.entities
            DROP COLUMN is_claimed;
        END IF;

        -- Create index on claim_status for efficient filtering
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market'
            AND tablename = 'entities'
            AND indexname = 'idx_entities_claim_status'
        ) THEN
            CREATE INDEX idx_entities_claim_status ON market.entities(claim_status);
        END IF;

        -- Create index on claim_requested_by for workflow queries
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market'
            AND tablename = 'entities'
            AND indexname = 'idx_entities_claim_requested_by'
        ) THEN
            CREATE INDEX idx_entities_claim_requested_by
            ON market.entities(claim_requested_by)
            WHERE claim_requested_by IS NOT NULL;
        END IF;

    END IF;
END $$;

-- Step 4: Migrate market.organizations table
DO $$
BEGIN
    -- Check if market.organizations table exists
    IF EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_schema = 'market'
        AND table_name = 'organizations'
    ) THEN

        -- Add new claim_status column with default 'claimed' for organizations
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'claim_status'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN claim_status claim_status_enum DEFAULT 'claimed';
        END IF;

        -- Add claim workflow metadata columns
        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'claim_requested_at'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN claim_requested_at TIMESTAMPTZ;
        END IF;

        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'claim_requested_by'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN claim_requested_by UUID REFERENCES shared.users(id);
        END IF;

        IF NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'claim_verification_method'
        ) THEN
            ALTER TABLE market.organizations
            ADD COLUMN claim_verification_method claim_verification_method_enum;
        END IF;

        -- Rename verified_at to claim_verified_at for clarity
        IF EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'verified_at'
        ) AND NOT EXISTS (
            SELECT FROM information_schema.columns
            WHERE table_schema = 'market'
            AND table_name = 'organizations'
            AND column_name = 'claim_verified_at'
        ) THEN
            ALTER TABLE market.organizations
            RENAME COLUMN verified_at TO claim_verified_at;
        END IF;

        -- Set all existing organizations to 'claimed' by default
        UPDATE market.organizations
        SET claim_status = 'claimed'::claim_status_enum
        WHERE claim_status IS NULL;

        -- Create index on claim_status
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market'
            AND tablename = 'organizations'
            AND indexname = 'idx_organizations_claim_status'
        ) THEN
            CREATE INDEX idx_organizations_claim_status ON market.organizations(claim_status);
        END IF;

        -- Create index on claim_requested_by
        IF NOT EXISTS (
            SELECT FROM pg_indexes
            WHERE schemaname = 'market'
            AND tablename = 'organizations'
            AND indexname = 'idx_organizations_claim_requested_by'
        ) THEN
            CREATE INDEX idx_organizations_claim_requested_by
            ON market.organizations(claim_requested_by)
            WHERE claim_requested_by IS NOT NULL;
        END IF;

    END IF;
END $$;

-- Add helpful comments
COMMENT ON COLUMN market.entities.claim_status IS 'Entity claim status: unclaimed, pending, claimed, restricted, banned';
COMMENT ON COLUMN market.entities.claim_requested_at IS 'Timestamp when claim was requested';
COMMENT ON COLUMN market.entities.claim_requested_by IS 'User who requested the claim';
COMMENT ON COLUMN market.entities.claim_verification_method IS 'Method used to verify the claim';
COMMENT ON COLUMN market.entities.claim_verified_at IS 'Timestamp when claim was verified';

COMMENT ON COLUMN market.organizations.claim_status IS 'Organization claim status: unclaimed, pending, claimed, restricted, banned (default: claimed)';
COMMENT ON COLUMN market.organizations.claim_requested_at IS 'Timestamp when claim was requested';
COMMENT ON COLUMN market.organizations.claim_requested_by IS 'User who requested the claim';
COMMENT ON COLUMN market.organizations.claim_verification_method IS 'Method used to verify the claim';
COMMENT ON COLUMN market.organizations.claim_verified_at IS 'Timestamp when claim was verified';
