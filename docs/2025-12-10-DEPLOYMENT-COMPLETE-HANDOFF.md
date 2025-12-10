# Sonik Infrastructure Deployment - Handoff Document

**Date:** 2025-12-10
**Status:** DEPLOYED AND RUNNING
**AWS Instance:** 18.191.215.116

---

## What Was Accomplished

### Phase 1: GitHub Setup
- Created repo: https://github.com/SonikFM/sonik-infra
- Pushed all infrastructure code to `main` branch

### Phase 2: AWS Deployment
- SSH'd into EC2 instance (18.191.215.116)
- Installed Docker 29.1.2 + Docker Compose plugin
- Cloned repo and configured environment
- Deployed full Cognee stack

---

## Running Services

| Service | Port | Status | URL |
|---------|------|--------|-----|
| **FalkorDB** | 6379 | Running (healthy) | Redis protocol |
| **RedisVL** | 6380 | Running (healthy) | Redis protocol |
| **RedisInsight** | 8001 | Running | http://18.191.215.116:8001 |
| **Cognee** | 8000 | Running | http://18.191.215.116:8000/docs |
| **NocoDB** | 8080 | Running | http://18.191.215.116:8080 |
| **Grist** | 8484 | Running | http://18.191.215.116:8484 |

---

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

---

## Configuration Details

### Environment Variables (.env on AWS)

```bash
# PostgreSQL (Supabase Pooler - IPv4 compatible)
POSTGRES_HOST=aws-0-us-east-2.pooler.supabase.com
POSTGRES_PORT=6543
POSTGRES_DB=postgres
POSTGRES_USER=<supabase-user>
POSTGRES_PASSWORD=<supabase-password>

# Redis
REDIS_PASSWORD=<redis-password>

# NocoDB
NOCODB_JWT_SECRET=<jwt-secret>

# Grist
GRIST_SESSION_SECRET=<session-secret>

# LLM Provider (for Cognee)
LLM_PROVIDER=openai
OPENAI_API_KEY=<openai-api-key>
```

> **Note:** Actual credentials are stored in `.env` on AWS server only. See env.template for variable names.

### Telemetry Status

| Service | Telemetry | How |
|---------|-----------|-----|
| NocoDB | Disabled | `NC_DISABLE_TELE=true` |
| Cognee | Disabled | `TELEMETRY_DISABLED=true` |
| Grist | Disabled | `GRIST_ALLOW_AUTOMATIC_VERSION_CHECKING=false` |
| FalkorDB | None | No telemetry built-in |
| RedisVL | None | No telemetry built-in |

---

## Key Decisions Made

### 1. NocoDB Metadata Storage
- **Decision:** SQLite for NocoDB metadata (not Supabase)
- **Reason:** Supabase direct connection is IPv6-only; EC2 doesn't have IPv6
- **Impact:** Connect to Supabase via NocoDB's UI after login

### 2. Supabase Pooler Connection
- **Decision:** Use `aws-0-us-east-2.pooler.supabase.com:6543` instead of direct
- **Reason:** Direct host (`db.jjdofmqlgsfgmdvnuakv.supabase.co`) resolves to IPv6 only
- **Future:** Enable IPv4 add-on on Supabase to use direct connection

### 3. RedisVL Status
- **Current:** Running but NOT connected to anything
- **Future:** Integrate as semantic cache layer for Cognee/LLM responses

---

## How Cognee Connects to Backends

| Backend | Connection | Purpose |
|---------|------------|---------|
| **FalkorDB** | `falkordb:6379` (Docker network) | Knowledge graph storage (OpenCypher) |
| **LanceDB** | `/data/lancedb` (embedded volume) | Vector embeddings |
| **PostgreSQL** | Supabase Pooler (external) | Relational data |

---

## SSH Access

```bash
# From local machine
ssh -i /path/to/sonik-os.pem ubuntu@18.191.215.116

# Key location in repo
sonik-os/sonik-os.pem
```

---

## Common Commands (on AWS)

```bash
# View running containers
sudo docker ps

# View logs
sudo docker logs sonik-cognee
sudo docker logs sonik-nocodb

# Restart all services
cd ~/sonik-infra/docker
sudo docker compose -f docker-compose.cognee-stack.yaml restart

# Full redeploy
sudo docker compose -f docker-compose.cognee-stack.yaml down
sudo docker compose -f docker-compose.cognee-stack.yaml up -d

# Pull latest from GitHub and redeploy
cd ~/sonik-infra && git pull
cd docker && sudo docker compose -f docker-compose.cognee-stack.yaml up -d --force-recreate
```

---

## AWS Security Group

**Required ports to open for external access:**
- 8000 (Cognee API)
- 8080 (NocoDB)
- 8484 (Grist)
- 8001 (RedisInsight) - optional, internal only recommended

---

## Visualization Research (For Future)

### Graph Visualization Tools Identified

| Tool | Type | Scale | Notes |
|------|------|-------|-------|
| **3d-force-graph** | JS/WebGL | ~100K nodes | VR support, stunning visuals |
| **deck.gl** | JS/WebGL | Millions | Uber's framework, 3D heatmaps |
| **React Native Filament** | Native | Millions | Metal/Vulkan, production-ready |
| **React Native Skia + WebGPU** | Native | Millions | Three.js compatible |

### Scale Limits

| Nodes | Browser | Native App |
|-------|---------|------------|
| 100K | Easy | Easy |
| 1M | GPU required | Easy |
| 10M | Streaming only | Possible |
| 2B | Server-side | Tile-based streaming |

### Attribution Graph Vision
- Conversations converging on ticket purchase
- 3D holographic visualization ("Star Wars" aesthetic)
- Heatmap + force-directed graph hybrid
- Real-time WebSocket updates

---

## Next Steps

1. **Open AWS Security Group ports** for external access
2. **Index a codebase** into Cognee
3. **Connect NocoDB to Supabase** via UI
4. **Update schema document** (`docs/SCHEMA-UPDATES-UNFINISHED-12-10.MD`)
5. **Integrate RedisVL** as semantic cache

---

## Files Modified/Created

| File | Action |
|------|--------|
| `docker/docker-compose.cognee-stack.yaml` | Updated - SQLite for NocoDB, telemetry disabled |
| `docker/.env` (on AWS only) | Created - production credentials |
| `docs/HANDOFF-NEXT-CHAT.md` | Created |
| `docs/2025-12-10-DEPLOYMENT-COMPLETE-HANDOFF.md` | Created (this file) |

---

## Repository

- **GitHub:** https://github.com/SonikFM/sonik-infra
- **Branch:** main
- **Latest commit:** `feat: disable telemetry for Cognee and Grist version checks`
