-- Sonik OS: Job Runs Table
-- Phase: 1 - Task 1.9
-- Date: 2025-12-08
-- Description: ETL job tracking for MongoDB → Supabase migration and ongoing sync

CREATE TABLE metadata.job_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Job identification
    job_name TEXT NOT NULL,
    job_type TEXT NOT NULL CHECK (
        job_type IN ('etl', 'sync', 'migration', 'cleanup', 'aggregation', 'other')
    ),

    -- Execution
    status TEXT DEFAULT 'running' CHECK (
        status IN ('running', 'success', 'failed', 'partial', 'cancelled')
    ),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_seconds NUMERIC,

    -- Stats
    records_processed INTEGER DEFAULT 0,
    records_inserted INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,

    -- Details
    error_message TEXT,
    error_details JSONB,
    job_config JSONB,
    result_summary JSONB,

    -- Metadata
    triggered_by TEXT,
    server_hostname TEXT,
    git_commit TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_job_runs_name ON metadata.job_runs(job_name);
CREATE INDEX idx_job_runs_type ON metadata.job_runs(job_type);
CREATE INDEX idx_job_runs_status ON metadata.job_runs(status);
CREATE INDEX idx_job_runs_started ON metadata.job_runs(started_at DESC);

COMMENT ON TABLE metadata.job_runs IS 'ETL job tracking for data migrations and sync operations';
