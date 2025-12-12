-- Sonik OS: Create Database Schemas
-- Phase: 1 - Task 1.3
-- Date: 2025-12-08
-- Description: Create 8 schemas for organizing Sonik OS data

-- Shared: Cross-org reference data
CREATE SCHEMA IF NOT EXISTS shared;
COMMENT ON SCHEMA shared IS 'Cross-organization reference data (users, currencies, countries)';

-- Market: Core business entities and relationships
CREATE SCHEMA IF NOT EXISTS market;
COMMENT ON SCHEMA market IS 'Organizations, customers, entities, and market intelligence';

-- Finance: Transactions, settlements, and revenue
CREATE SCHEMA IF NOT EXISTS finance;
COMMENT ON SCHEMA finance IS 'Tickets, transactions, payments, settlements, and financial tracking';

-- Attribution: Marketing attribution and traffic sources
CREATE SCHEMA IF NOT EXISTS attribution;
COMMENT ON SCHEMA attribution IS 'Amplify attribution, UTMs, touchpoints, and conversion tracking';

-- Content: Knowledge base and amplification content
CREATE SCHEMA IF NOT EXISTS content;
COMMENT ON SCHEMA content IS 'Articles, cities, venues, amplification content';

-- Operations: Operational workflows and tools
CREATE SCHEMA IF NOT EXISTS operations;
COMMENT ON SCHEMA operations IS 'Support tickets, staff workflows, and internal tools';

-- Analytics: Materialized views and aggregations
CREATE SCHEMA IF NOT EXISTS analytics;
COMMENT ON SCHEMA analytics IS 'Pre-computed metrics, rollups, and dashboards';

-- Metadata: System metadata and ETL tracking
CREATE SCHEMA IF NOT EXISTS metadata;
COMMENT ON SCHEMA metadata IS 'Job runs, data quality, and ETL metadata';

-- List all schemas
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('shared', 'market', 'finance', 'attribution', 'content', 'operations', 'analytics', 'metadata')
ORDER BY schema_name;
