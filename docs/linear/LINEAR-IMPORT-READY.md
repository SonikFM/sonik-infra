# Linear Import Ready - Sonik Infrastructure

> **Instructions:** Copy each section below into Linear. Create the project first, then add the document, then create issues with their sub-issues.

---

## 1. CREATE PROJECT

**Project Name:** `sonik-infra`
**Team:** Sonik
**Description:** Infrastructure documentation and operational tasks for Sonik backend services. Bridge to Forge.

---

## 2. ADD PROJECT DOCUMENT

**Document Title:** Infrastructure Overview

**Content:** (Copy everything below this line into the document)

# Sonik Infrastructure Overview

## Purpose

This project contains all infrastructure documentation for Sonik's backend services. It serves as a bridge to Forge and the source of truth for:

- AWS access and commands
- Credential locations
- Service configurations
- Database connections

## Quick Reference

### SSH into AWS
```bash
ssh -i /Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

### Service URLs
| Service | URL |
|---------|-----|
| Cognee API | http://18.191.215.116:8000/docs |
| NocoDB | http://18.191.215.116:8080 |
| Grist | http://18.191.215.116:8484 |
| RedisInsight | http://18.191.215.116:8001 |

### Credential Location
```
AWS Server: ~/sonik-infra/docker/.env
```

## Documentation Index

| Document | Location | Description |
|----------|----------|-------------|
| AWS Access | [GitHub](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/01-aws-access.md) | SSH access, common commands |
| Credential Locations | [GitHub](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/02-credential-locations.md) | Where secrets are stored |
| Cognee Stack | [GitHub](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/03-cognee-stack-services.md) | All services, ports, health checks |
| Supabase | [GitHub](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/04-supabase.md) | Database connections |

## Related Resources

- **GitHub:** https://github.com/SonikFM/sonik-infra
- **Supabase:** https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv
- **AWS Instance:** 18.191.215.116

## Deployment Date

- **Initial Deployment:** 2025-12-10
- **Last Updated:** 2025-12-10

---

## 3. CREATE ISSUES

### ISSUE 1: AWS Security Group Configuration

**Title:** Open AWS Security Group ports for external access
**Priority:** High (Urgent)
**Labels:** `infrastructure`, `aws`

**Description:**
Configure AWS Security Group to allow external access to deployed services.

**Required ports to open:**
- 8000 (Cognee API) - Required for API access
- 8080 (NocoDB) - Required for spreadsheet UI
- 8484 (Grist) - Required for smart spreadsheets
- 8001 (RedisInsight) - Optional, recommend internal only

**Reference:** [AWS Access Doc](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/01-aws-access.md)

#### Sub-issues for Issue 1:

**1.1** Log into AWS Console and navigate to Security Groups
- Find the security group attached to instance 18.191.215.116
- Document current inbound rules

**1.2** Add inbound rule for Cognee API (port 8000)
- Protocol: TCP
- Port: 8000
- Source: 0.0.0.0/0 (or restrict to specific IPs)

**1.3** Add inbound rule for NocoDB (port 8080)
- Protocol: TCP
- Port: 8080
- Source: 0.0.0.0/0

**1.4** Add inbound rule for Grist (port 8484)
- Protocol: TCP
- Port: 8484
- Source: 0.0.0.0/0

**1.5** Verify all services accessible from external network
- Test each URL from non-AWS network
- Document any issues

---

### ISSUE 2: Index Codebase into Cognee

**Title:** Index first codebase into Cognee
**Priority:** Medium
**Labels:** `infrastructure`, `cognee`

**Description:**
Select a repository and index it into Cognee for testing the knowledge graph and semantic search capabilities.

**Goals:**
- Validate Cognee ingestion pipeline
- Test semantic search accuracy
- Verify knowledge graph creation
- Benchmark query performance

**Reference:** [Cognee Stack Doc](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/03-cognee-stack-services.md)

#### Sub-issues for Issue 2:

**2.1** Choose target repository for indexing
- Evaluate: sonik-infra, sonik-portal, or another repo
- Consider size and complexity for initial test

**2.2** Configure Cognee ingestion settings
- Set up file filters (e.g., only .ts, .py, .md files)
- Configure chunking strategy
- Set embedding model

**2.3** Run initial indexing job
- Monitor logs: `sudo docker logs sonik-cognee -f`
- Track indexing progress
- Note any errors

**2.4** Test semantic search queries
- Query: "How do I SSH into the server?"
- Query: "What services are running?"
- Query: "Where are credentials stored?"
- Document response quality

**2.5** Validate knowledge graph in FalkorDB
- Connect to FalkorDB (port 6379)
- Run Cypher queries to explore graph
- Document entity relationships

---

### ISSUE 3: RedisVL Semantic Cache Integration

**Title:** Integrate RedisVL as semantic cache layer
**Priority:** Low
**Labels:** `infrastructure`, `redis`, `performance`

**Description:**
RedisVL is running (port 6380) but not connected to any service. Integrate it as a semantic cache to improve LLM response times.

**Goals:**
- Reduce duplicate LLM API calls
- Improve response latency
- Lower OpenAI costs

**Reference:** [Cognee Stack Doc](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/03-cognee-stack-services.md)

#### Sub-issues for Issue 3:

**3.1** Research Cognee + RedisVL integration
- Check Cognee docs for cache configuration
- Identify environment variables needed
- Review RedisVL semantic cache examples

**3.2** Configure Cognee to use RedisVL
- Update docker-compose environment
- Set cache TTL and similarity threshold
- Restart Cognee container

**3.3** Implement cache invalidation strategy
- Define when cache should be cleared
- Set up manual invalidation endpoint
- Document invalidation triggers

**3.4** Benchmark performance improvement
- Measure response time without cache
- Measure response time with cache hit
- Calculate cost savings estimate

---

### ISSUE 4: Supabase Schema Updates

**Title:** Complete Supabase schema updates
**Priority:** High (Urgent)
**Labels:** `database`, `supabase`

**Description:**
Schema updates are pending from previous session. This blocks other database-dependent features.

**Reference:**
- Local: `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`
- [Supabase Doc](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/04-supabase.md)

**Supabase Dashboard:** https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv

#### Sub-issues for Issue 4:

**4.1** Review pending schema changes
- Read `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`
- List all pending migrations
- Identify dependencies between changes

**4.2** Create migration scripts
- Write SQL for each schema change
- Include rollback scripts
- Test in local/staging first

**4.3** Execute schema updates in Supabase
- Run migrations via Supabase SQL Editor
- Verify each change completed
- Update documentation

**4.4** Validate connected services still work
- Test Cognee PostgreSQL connection
- Verify NocoDB can connect (if configured)
- Check any other dependent services

---

### ISSUE 5: PG18 Database Migration

**Title:** Create PG18 database to complete database updates
**Priority:** High (Urgent)
**Labels:** `database`, `supabase`, `migration`

**Description:**
Migrate to PostgreSQL 18 to resolve ongoing database update issues and gain access to latest features.

**Goals:**
- Resolve compatibility issues blocking updates
- Gain PG18 performance improvements
- Future-proof database infrastructure

**Reference:** [Supabase Doc](https://github.com/SonikFM/sonik-infra/blob/main/docs/linear/04-supabase.md)

#### Sub-issues for Issue 5:

**5.1** Research PG18 compatibility with Supabase
- Check Supabase PG18 support status
- Identify breaking changes from current version
- Review pgvector compatibility

**5.2** Plan migration strategy
- Decide: new project vs upgrade existing
- Plan data migration approach
- Estimate downtime window

**5.3** Create new PG18 database (if new project approach)
- Create new Supabase project with PG18
- Configure pooler settings
- Set up same extensions (pgvector, etc.)

**5.4** Migrate data to new database
- Export data from current database
- Import into PG18 database
- Verify data integrity

**5.5** Update all service connections
- Update .env on AWS server
- Update docker-compose if needed
- Restart all services
- Validate connections

**5.6** Decommission old database (after validation)
- Confirm all services working on new DB
- Create final backup of old DB
- Archive or delete old project

---

## Summary

**Total Issues:** 5
**Total Sub-issues:** 21

| Issue | Priority | Sub-issues |
|-------|----------|------------|
| AWS Security Group | High | 5 |
| Cognee Indexing | Medium | 5 |
| RedisVL Integration | Low | 4 |
| Supabase Schema | High | 4 |
| PG18 Migration | High | 6 |
