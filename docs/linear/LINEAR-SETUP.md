# Linear Project Setup - Sonik Infrastructure

## Project Details

**Project Name:** sonik-infra
**Team:** Sonik (or appropriate team)
**Type:** Documentation / Infrastructure

## Documents to Add

Add each markdown file from `docs/linear/` as a Linear document:

1. `00-infrastructure-overview.md` → "Infrastructure Overview"
2. `01-aws-access.md` → "AWS Access"
3. `02-credential-locations.md` → "Credential Locations"
4. `03-cognee-stack-services.md` → "Cognee Stack Services"
5. `04-supabase.md` → "Supabase"

## Issues to Create

### Issue 1: Next Steps - Security Group Configuration
**Title:** Open AWS Security Group ports for external access
**Description:**
Required ports to open:
- 8000 (Cognee API)
- 8080 (NocoDB)
- 8484 (Grist)
- 8001 (RedisInsight) - optional, internal only recommended

**Priority:** High
**Labels:** infrastructure, aws

### Issue 2: Next Steps - Index Codebase into Cognee
**Title:** Index first codebase into Cognee
**Description:**
Select a repository and index it into Cognee for testing:
1. Choose target repo
2. Configure Cognee ingestion
3. Test semantic search
4. Validate knowledge graph

**Priority:** Medium
**Labels:** infrastructure, cognee

### Issue 3: Next Steps - RedisVL Integration
**Title:** Integrate RedisVL as semantic cache layer
**Description:**
RedisVL is running but not connected. Tasks:
1. Configure Cognee to use RedisVL for caching
2. Set up cache invalidation strategy
3. Test performance improvement

**Priority:** Low
**Labels:** infrastructure, redis

### Issue 4: Supabase - Schema Updates
**Title:** Complete Supabase schema updates
**Description:**
Reference: `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`

Schema updates are pending from previous session. This is tracked separately.

**Priority:** High
**Labels:** database, supabase

### Issue 5: Supabase - PG18 Database Migration
**Title:** Create PG18 database to complete database updates
**Description:**
Migrate to PostgreSQL 18 to resolve ongoing database update issues.

Tasks:
1. Research PG18 compatibility with Supabase
2. Plan migration strategy
3. Execute migration
4. Validate all services

**Priority:** High
**Labels:** database, supabase, migration
