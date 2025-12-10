# Sonik Infrastructure

Consolidated infrastructure for Sonik's AI memory and data layer.

## Architecture

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

## Stack

| Service | Port | Purpose |
|---------|------|---------|
| FalkorDB | 6379 | Graph database (OpenCypher) |
| RedisVL | 6380 | Semantic caching, vector search |
| RedisInsight | 8001 | Redis management UI |
| Cognee | 8000 | AI memory orchestration |
| NocoDB | 8080 | Spreadsheet UI for PostgreSQL |
| Grist | 8484 | Smart spreadsheets |

## Quick Start

### 1. Configure Environment

```bash
cd docker
cp .env.template .env
# Edit .env with your PostgreSQL credentials
```

### 2. Deploy

```bash
./scripts/deploy-cognee-stack.sh
```

### 3. Verify

```bash
./scripts/health-check.sh
```

## Services

### Cognee
AI memory orchestration that manages:
- **Graph storage**: FalkorDB for knowledge graphs
- **Vector storage**: LanceDB (embedded) for semantic search
- **Relational storage**: Your existing PostgreSQL

### FalkorDB
Redis-based graph database supporting OpenCypher queries. Sub-millisecond traversals.

### RedisVL
Semantic caching layer with vector search capabilities for LLM response caching.

### NocoDB
Airtable alternative providing spreadsheet UI for your PostgreSQL tables.

### Grist
Smart spreadsheets with formulas and Python calculations.

## PostgreSQL

This stack connects to your **existing PostgreSQL** database (Supabase Cloud).
No schemas are created - your migrations handle that separately.

## AWS Deployment

See `docs/2025-12-10-SONIK-INFRASTRUCTURE-HANDOFF.md` for AWS instance setup instructions.

**Instance**: `18.191.215.116`
**User**: `ubuntu`
**Key**: `sonik-os.pem`

## Directory Structure

```
sonik-infra/
├── docker/
│   ├── docker-compose.cognee-stack.yaml
│   └── .env.template
├── scripts/
│   ├── deploy-cognee-stack.sh
│   └── health-check.sh
└── docs/
    ├── 2025-12-10-cognee-data-layer-deployment.md
    └── 2025-12-10-SONIK-INFRASTRUCTURE-HANDOFF.md
```

## Commands

```bash
# Deploy
./scripts/deploy-cognee-stack.sh

# Health check
./scripts/health-check.sh

# View logs
docker-compose -f docker/docker-compose.cognee-stack.yaml logs -f

# Stop
docker-compose -f docker/docker-compose.cognee-stack.yaml down

# Full reset (removes data)
docker-compose -f docker/docker-compose.cognee-stack.yaml down -v
```
