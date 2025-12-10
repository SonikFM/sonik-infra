# Sonik Infrastructure Documentation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create modular infrastructure documentation as markdown files ready for Linear import, plus Linear project with issues for next steps.

**Architecture:** Multiple standalone markdown documents (one per domain) that can be added to Linear as separate docs. Each document is self-contained with all necessary context. Linear project tracks actionable items.

**Tech Stack:** Markdown, Linear API (if available), Git

---

## Task 1: Create AWS Access Document

**Files:**
- Create: `docs/linear/01-aws-access.md`

**Step 1: Write the AWS access document**

```markdown
# AWS Access - Sonik Infrastructure

## Instance Details

| Property | Value |
|----------|-------|
| **IP Address** | 18.191.215.116 |
| **User** | ubuntu |
| **Region** | us-east-2 (Ohio) |

## SSH Access

**Key Location:**
```
/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem
```

**SSH Command:**
```bash
ssh -i /Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

## Common Commands

**View running containers:**
```bash
sudo docker ps
```

**View logs for a service:**
```bash
sudo docker logs sonik-cognee
sudo docker logs sonik-nocodb
sudo docker logs sonik-falkordb
```

**Restart all services:**
```bash
cd ~/sonik-infra/docker
sudo docker compose -f docker-compose.cognee-stack.yaml restart
```

**Full redeploy:**
```bash
cd ~/sonik-infra/docker
sudo docker compose -f docker-compose.cognee-stack.yaml down
sudo docker compose -f docker-compose.cognee-stack.yaml up -d
```

**Pull latest and redeploy:**
```bash
cd ~/sonik-infra && git pull
cd docker && sudo docker compose -f docker-compose.cognee-stack.yaml up -d --force-recreate
```

## GitHub Repository

- **Repo:** https://github.com/SonikFM/sonik-infra
- **Branch:** main
- **Local Path:** `/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra`
```

**Step 2: Commit**

```bash
git add docs/linear/01-aws-access.md
git commit -m "docs: add AWS access guide for Linear"
```

---

## Task 2: Create Credential Locations Document

**Files:**
- Create: `docs/linear/02-credential-locations.md`

**Step 1: Write the credential locations document**

```markdown
# Credential Locations - Sonik Infrastructure

## Overview

All credentials are stored in environment files on the respective servers. This document tracks WHERE credentials live, not the credentials themselves.

## AWS Environment File

**Location on AWS server:**
```
~/sonik-infra/docker/.env
```

**How to view:**
```bash
ssh -i /path/to/sonik-os.pem ubuntu@18.191.215.116
cat ~/sonik-infra/docker/.env
```

**Variables stored:**
| Variable | Purpose |
|----------|---------|
| `POSTGRES_HOST` | Supabase pooler hostname |
| `POSTGRES_PORT` | Supabase pooler port (6543) |
| `POSTGRES_DB` | Database name |
| `POSTGRES_USER` | Supabase user |
| `POSTGRES_PASSWORD` | Supabase password |
| `REDIS_PASSWORD` | Redis/RedisVL password |
| `NOCODB_JWT_SECRET` | NocoDB authentication secret |
| `GRIST_SESSION_SECRET` | Grist session secret |
| `LLM_PROVIDER` | LLM provider (openai) |
| `OPENAI_API_KEY` | OpenAI API key for Cognee |

## Supabase Dashboard

**URL:** https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv

**Where to find credentials:**
1. Project Settings > Database
2. Connection string section
3. Use "Pooler" connection (IPv4 compatible)

## Local Template

**Location:**
```
/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra/docker/.env.template
```

This template shows required variables without actual values.

## Future: Vault Migration

When vault is implemented, this document will be updated with:
- Vault paths for each credential
- Access policies
- Rotation schedules
```

**Step 2: Commit**

```bash
git add docs/linear/02-credential-locations.md
git commit -m "docs: add credential locations guide for Linear"
```

---

## Task 3: Create Cognee Stack Services Document

**Files:**
- Create: `docs/linear/03-cognee-stack-services.md`

**Step 1: Write the Cognee stack services document**

```markdown
# Cognee Stack Services - Sonik Infrastructure

## Architecture Overview

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    COGNEE (Orchestrator)                    │
                    │         Knowledge Graph + AI Memory + Semantic Search       │
                    │                      Port: 8000                             │
                    └─────────────────┬──────────────────┬──────────────────┬─────┘
                                      │                  │                  │
                             ┌────────▼───────┐ ┌────────▼───────┐ ┌───────▼────────┐
                             │   PostgreSQL   │ │   FalkorDB     │ │    LanceDB     │
                             │   (External)   │ │ (on Redis 7.4) │ │   (Embedded)   │
                             │ Supabase Cloud │ │   Port: 6379   │ │   Local Files  │
                             └────────────────┘ └────────────────┘ └────────────────┘

                                                ┌────────────────┐
                                                │    RedisVL     │
                                                │ Semantic Cache │
                                                │   Port: 6380   │
                                                └────────────────┘

                        ┌───────────┐    ┌───────────┐
                        │  NocoDB   │    │   Grist   │
                        │   :8080   │    │   :8484   │
                        └───────────┘    └───────────┘
```

## Service Details

### Cognee (AI Memory Orchestration)
| Property | Value |
|----------|-------|
| **Port** | 8000 |
| **URL** | http://18.191.215.116:8000/docs |
| **Container** | sonik-cognee |
| **Purpose** | Knowledge graph + AI memory + semantic search |
| **Backends** | FalkorDB (graph), LanceDB (vectors), PostgreSQL (relational) |

### FalkorDB (Graph Database)
| Property | Value |
|----------|-------|
| **Port** | 6379 |
| **Protocol** | Redis (OpenCypher queries) |
| **Container** | sonik-falkordb |
| **Purpose** | Knowledge graph storage |
| **Data Volume** | falkordb_data |

### RedisVL (Semantic Cache)
| Property | Value |
|----------|-------|
| **Port** | 6380 |
| **UI Port** | 8001 (RedisInsight) |
| **URL** | http://18.191.215.116:8001 |
| **Container** | sonik-redisvl |
| **Purpose** | Semantic caching for LLM responses |
| **Status** | Running but NOT integrated yet |

### NocoDB (Spreadsheet UI)
| Property | Value |
|----------|-------|
| **Port** | 8080 |
| **URL** | http://18.191.215.116:8080 |
| **Container** | sonik-nocodb |
| **Purpose** | Spreadsheet interface for databases |
| **Metadata** | SQLite (local) |
| **External DBs** | Connect via UI after login |

### Grist (Smart Spreadsheets)
| Property | Value |
|----------|-------|
| **Port** | 8484 |
| **URL** | http://18.191.215.116:8484 |
| **Container** | sonik-grist |
| **Purpose** | Smart spreadsheets with formulas |
| **Org** | sonik |

### LanceDB (Vector Store)
| Property | Value |
|----------|-------|
| **Type** | Embedded (inside Cognee) |
| **Path** | /data/lancedb (container volume) |
| **Purpose** | Vector embeddings for semantic search |

## Health Checks

**Quick status:**
```bash
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Service-specific:**
```bash
# Cognee
curl http://18.191.215.116:8000/health

# FalkorDB (Redis ping)
redis-cli -h 18.191.215.116 -p 6379 ping

# RedisVL (requires password)
redis-cli -h 18.191.215.116 -p 6380 -a <password> ping
```

## Telemetry Status

All services have telemetry disabled:

| Service | Method |
|---------|--------|
| Cognee | `TELEMETRY_DISABLED=true` |
| NocoDB | `NC_DISABLE_TELE=true` |
| Grist | `GRIST_ALLOW_AUTOMATIC_VERSION_CHECKING=false` |
| FalkorDB | No telemetry built-in |
| RedisVL | No telemetry built-in |
```

**Step 2: Commit**

```bash
git add docs/linear/03-cognee-stack-services.md
git commit -m "docs: add Cognee stack services guide for Linear"
```

---

## Task 4: Create Supabase Document

**Files:**
- Create: `docs/linear/04-supabase.md`

**Step 1: Write the Supabase document**

```markdown
# Supabase - Sonik Infrastructure

## Project Details

| Property | Value |
|----------|-------|
| **Project ID** | jjdofmqlgsfgmdvnuakv |
| **Dashboard** | https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv |
| **Region** | us-east-2 |

## Connection Options

### Pooler Connection (RECOMMENDED)

Use this for AWS EC2 (IPv4 only):

| Property | Value |
|----------|-------|
| **Host** | aws-0-us-east-2.pooler.supabase.com |
| **Port** | 6543 |
| **Database** | postgres |
| **User** | postgres.jjdofmqlgsfgmdvnuakv |

**Why Pooler?** Direct connection resolves to IPv6 only. EC2 instance doesn't have IPv6 enabled.

### Direct Connection (IPv6 Required)

| Property | Value |
|----------|-------|
| **Host** | db.jjdofmqlgsfgmdvnuakv.supabase.co |
| **Port** | 5432 |
| **Database** | postgres |
| **User** | postgres |

**Note:** Only use if IPv4 add-on is enabled on Supabase or connecting from IPv6-capable host.

## Current Usage

| Service | Connection Type | Purpose |
|---------|----------------|---------|
| Cognee | Pooler | Relational data storage |
| NocoDB | None (SQLite metadata) | Connect via UI |

## Schema Updates

**Status:** Pending

**Document:** `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`

**Related Issues:**
- Schema updates implementation
- PG18 database migration

## Future: IPv4 Add-on

To enable direct connection from EC2:
1. Go to Supabase Dashboard > Project Settings > Add-ons
2. Enable IPv4 add-on
3. Update .env to use direct host
```

**Step 2: Commit**

```bash
git add docs/linear/04-supabase.md
git commit -m "docs: add Supabase connection guide for Linear"
```

---

## Task 5: Create Infrastructure Overview Document

**Files:**
- Create: `docs/linear/00-infrastructure-overview.md`

**Step 1: Write the infrastructure overview document**

```markdown
# Sonik Infrastructure Overview

## Purpose

This project contains all infrastructure documentation for Sonik's backend services. It serves as a bridge to Forge and the source of truth for:

- AWS access and commands
- Credential locations
- Service configurations
- Database connections

## Document Index

| # | Document | Description |
|---|----------|-------------|
| 01 | [AWS Access](./01-aws-access.md) | SSH access, common commands, GitHub repo |
| 02 | [Credential Locations](./02-credential-locations.md) | Where all secrets are stored |
| 03 | [Cognee Stack Services](./03-cognee-stack-services.md) | All services, ports, health checks |
| 04 | [Supabase](./04-supabase.md) | Database connections, pooler vs direct |

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

## Related Resources

- **GitHub:** https://github.com/SonikFM/sonik-infra
- **Supabase:** https://supabase.com/dashboard/project/jjdofmqlgsfgmdvnuakv
- **Schema Updates:** `docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`

## Deployment Date

- **Initial Deployment:** 2025-12-10
- **Last Updated:** 2025-12-10
```

**Step 2: Commit**

```bash
git add docs/linear/00-infrastructure-overview.md
git commit -m "docs: add infrastructure overview for Linear"
```

---

## Task 6: Create Linear Project and Issues (Manual or API)

**Files:**
- Create: `docs/linear/LINEAR-SETUP.md` (instructions if API unavailable)

**Step 1: Document Linear setup instructions**

```markdown
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
```

**Step 2: Commit**

```bash
git add docs/linear/LINEAR-SETUP.md
git commit -m "docs: add Linear project setup instructions"
```

---

## Task 7: Final Commit and Push

**Step 1: Push all documentation to GitHub**

```bash
git push origin main
```

**Step 2: Verify push succeeded**

Check: https://github.com/SonikFM/sonik-infra/tree/main/docs/linear

---

## Summary

After completing all tasks:

**Created Documents (for Linear import):**
1. `docs/linear/00-infrastructure-overview.md` - Index and quick reference
2. `docs/linear/01-aws-access.md` - SSH, commands, repo
3. `docs/linear/02-credential-locations.md` - Where secrets live
4. `docs/linear/03-cognee-stack-services.md` - All services detailed
5. `docs/linear/04-supabase.md` - Database connections
6. `docs/linear/LINEAR-SETUP.md` - Linear project/issue setup guide

**Linear Issues to Create:**
1. Open AWS Security Group ports
2. Index first codebase into Cognee
3. Integrate RedisVL as semantic cache
4. Complete Supabase schema updates
5. Create PG18 database migration
