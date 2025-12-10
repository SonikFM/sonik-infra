# Sonik Infrastructure Consolidation - Handoff Prompt

**Date:** 2025-12-10
**Status:** Ready for execution
**Goal:** Get Cognee data layer LIVE on AWS with consolidated infrastructure

---

## Copy This to New Chat

```
I need to consolidate Sonik's infrastructure repos and deploy the Cognee data layer to AWS.

## What's Been Done

1. **Architecture Decided:**
   - Cognee (AI memory orchestration)
   - FalkorDB (graph database on Redis)
   - LanceDB (vector embeddings - embedded)
   - RedisVL (semantic caching)
   - NocoDB (spreadsheet UI for Postgres)
   - Grist (smart spreadsheets)
   - PostgreSQL via existing Supabase Cloud (Sonik Echo project)

2. **Docker Compose Created:** `sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml`
   - All services configured
   - Connects to external PostgreSQL (your existing Supabase)
   - .env template ready

3. **Scripts Created:**
   - `sonik-os-orchestration/scripts/deploy-cognee-stack.sh`
   - `sonik-os-orchestration/scripts/health-check.sh`

4. **Key Discoveries:**
   - Cognee is ALREADY cloned in `sonik-echo/cognee/` (full repo with docker-compose)
   - Grist is in `sonik-os/GRIST.md/`
   - Autobase is in `sonik-os-gateway/` (for PG management)
   - NocoDB needs to be cloned: https://github.com/nocodb/nocodb.git

## What Needs to Happen Now

### Phase 1: Consolidate Infrastructure (30 min)

1. **Create new repo or rename:**
   - Option A: Rename `sonik-os-gateway` → `sonik-infrastructure`
   - Option B: Create new `sonik-infrastructure` repo
   - Decision: [USER TO DECIDE]

2. **Clone missing repos as submodules or copies:**
   - NocoDB: `git clone https://github.com/nocodb/nocodb.git`
   - Move/reference existing: Cognee (from sonik-echo), Grist, Autobase

3. **Directory structure should be:**
   ```
   sonik-infrastructure/
   ├── cognee/           # From sonik-echo/cognee
   ├── falkordb/         # Just docker config, no clone needed
   ├── grist/            # From GRIST.md or fresh clone
   ├── nocodb/           # Clone from GitHub
   ├── autobase/         # Already in gateway
   ├── redisvl/          # Just docker config
   ├── docker-compose.yaml  # Master compose file
   └── scripts/
       ├── deploy.sh
       └── health-check.sh
   ```

### Phase 2: Disable Telemetry (15 min)

Before deploying, disable telemetry in each service:
- **NocoDB:** `NC_DISABLE_TELEMETRY=true` in env
- **Grist:** Check docs for telemetry flag
- **Cognee:** Check .env.template for telemetry settings
- **FalkorDB:** Usually none
- **RedisVL:** Usually none

### Phase 3: Build Custom Images (30 min)

Create Dockerfiles that:
1. Use official base images
2. Apply Sonik branding/config
3. Disable telemetry by default
4. Tag as `sonik/service-name:latest`

### Phase 4: Deploy to AWS (30 min)

**AWS Instance Ready:**
- IP: `18.191.215.116`
- SSH Key: `sonik-os.pem` (in sonik-os root)
- User: `ubuntu` (standard AWS Ubuntu AMI)

**Step 1: SSH into instance**
```bash
ssh -i ~/.ssh/sonik-os.pem ubuntu@18.191.215.116
# OR if key is in repo:
ssh -i /path/to/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

**Step 2: Install Docker + Docker Compose (copy-paste this block)**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker ubuntu

# Install Docker Compose plugin
sudo apt install docker-compose-plugin -y

# Verify
docker --version
docker compose version

# Re-login to apply group (or just use sudo)
exit
```

**Step 3: Re-SSH and clone repo**
```bash
ssh -i ~/.ssh/sonik-os.pem ubuntu@18.191.215.116

# Clone the repo (or just the docker files)
git clone https://github.com/YOUR_ORG/sonik-infrastructure.git
cd sonik-infrastructure
```

**Step 4: Configure .env**
```bash
cp .env.template .env
nano .env  # or vim
```

Add Supabase credentials:
   ```
   POSTGRES_HOST=db.jjdofmqlgsfgmdvnuakv.supabase.co
   POSTGRES_PORT=5432
   POSTGRES_DB=postgres
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=[from Supabase dashboard]
   ```
**Step 5: Deploy**
```bash
./scripts/deploy.sh
# OR manually:
docker compose up -d
```

**Step 6: Verify**
```bash
./scripts/health-check.sh
# OR manually:
docker ps
curl localhost:8000/health  # Cognee
curl localhost:8080         # NocoDB
```

**Step 7: Open firewall ports (if needed)**
```bash
# AWS Security Group should allow:
# - 8000 (Cognee API)
# - 8080 (NocoDB)
# - 8484 (Grist)
# - 8001 (RedisInsight - optional, internal only)
```

### Phase 5: CI/CD Setup (Future)

- GitHub Actions for image builds
- Push to Docker Hub or ECR
- Auto-deploy on merge to main

## Existing Files to Reference

- Plan: `docs/plans/2025-12-10-cognee-data-layer-deployment.md`
- Docker Compose: `sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml`
- Deploy script: `sonik-os-orchestration/scripts/deploy-cognee-stack.sh`
- Health check: `sonik-os-orchestration/scripts/health-check.sh`

## Supabase Connection (Sonik Echo)

- Project: Sonik Echo
- Reference ID: jjdofmqlgsfgmdvnuakv
- Host: db.jjdofmqlgsfgmdvnuakv.supabase.co
- Port: 5432
- Database: postgres
- User: postgres
- Password: [Get from Supabase dashboard - do NOT use the secret key, use DB password]

## Services & Ports

| Service | Port | Notes |
|---------|------|-------|
| FalkorDB | 6379 | Graph database |
| RedisVL | 6380 | Semantic cache |
| RedisInsight | 8001 | Redis UI |
| Cognee | 8000 | AI memory API |
| NocoDB | 8080 | Spreadsheet UI |
| Grist | 8484 | Smart spreadsheets |

## Priority

1. GET IT LIVE - don't over-engineer
2. Consolidate repos
3. Disable telemetry
4. Deploy to AWS
5. CI/CD can come later

Start with Phase 1 - ask user: "New repo or rename gateway?"
```

---

## Session Context (For Reference)

### What We Learned This Session

1. **Dropped from architecture:**
   - Supabase (can't run AGE, locked to PG15)
   - Apache AGE (FalkorDB provides Cypher)
   - TimescaleDB (UUIDv7 provides time-ordering)
   - Neo4j (FalkorDB is sufficient)
   - Separate PG16 instance (not needed)

2. **New stack confirmed:**
   - Cognee orchestrates everything
   - FalkorDB for graph (OpenCypher)
   - LanceDB for vectors (embedded in Cognee)
   - RedisVL for semantic caching
   - PostgreSQL stays on Supabase Cloud (existing migrations)

3. **PostgreSQL schemas:**
   - 26 migrations already deployed to Supabase
   - Separate migration document exists
   - Infrastructure deployment does NOT touch schemas

### Files Modified/Created This Session

| File | Status |
|------|--------|
| `docs/plans/2025-12-10-cognee-data-layer-deployment.md` | Created - clean plan |
| `sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml` | Created |
| `sonik-os-orchestration/docker/.env.cognee-stack` | Created (template) |
| `sonik-os-orchestration/docker/.env` | Created (with Supabase creds) |
| `sonik-os-orchestration/scripts/deploy-cognee-stack.sh` | Created |
| `sonik-os-orchestration/scripts/health-check.sh` | Created |
| `docs/plans/2025-12-09-graph-database-unified-schema.md` | OUTDATED - replaced |

### Key Decisions Made

- **Supabase:** Keep for PostgreSQL hosting, drop everything else
- **Graph DB:** FalkorDB (not AGE, not Neo4j)
- **AI Memory:** Cognee orchestrates all storage backends
- **Vectors:** LanceDB (embedded in Cognee)
- **Caching:** RedisVL
- **UIs:** NocoDB + Grist
