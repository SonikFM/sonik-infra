# Cognee Data Layer Deployment Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Deploy Cognee stack infrastructure (FalkorDB, RedisVL, NocoDB, Grist) - PostgreSQL schemas already exist and are managed separately.

**Architecture:** Cognee orchestrates FalkorDB (graph), LanceDB (vectors), and connects to your existing PostgreSQL. NocoDB and Grist provide spreadsheet UIs.

**Tech Stack:** Docker Compose, FalkorDB, RedisVL, Cognee, NocoDB, Grist

**Note:** PostgreSQL schemas/migrations are handled in a separate document. This plan is infrastructure-only.

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
         │  Your existing │ │   Port: 6379   │ │   Local Files  │
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

## Task 1: Create Docker Compose (Infrastructure Only)

**Files:**
- Create: `sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml`
- Create: `sonik-os-orchestration/docker/.env.cognee-stack`

**Step 1: Create directory if needed**

```bash
mkdir -p sonik-os-orchestration/docker
```

**Step 2: Create Docker Compose file**

```yaml
# docker-compose.cognee-stack.yaml
# Cognee Data Layer - Infrastructure Only
# PostgreSQL is external (your existing database)

version: '3.8'

services:
  # ============================================
  # FalkorDB - Graph Database (runs on Redis)
  # ============================================
  falkordb:
    image: falkordb/falkordb:latest
    container_name: sonik-falkordb
    ports:
      - "6379:6379"
    volumes:
      - falkordb_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - sonik-network

  # ============================================
  # RedisVL - Semantic Caching + Vector Search
  # ============================================
  redisvl:
    image: redis/redis-stack:latest
    container_name: sonik-redisvl
    ports:
      - "6380:6379"
      - "8001:8001"  # RedisInsight UI
    environment:
      REDIS_ARGS: "--requirepass ${REDIS_PASSWORD:-sonik}"
    volumes:
      - redisvl_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD:-sonik}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - sonik-network

  # ============================================
  # Cognee - AI Memory Orchestration
  # ============================================
  cognee:
    image: cognee/cognee:latest
    container_name: sonik-cognee
    ports:
      - "8000:8000"
    environment:
      # PostgreSQL - YOUR EXISTING DATABASE
      COGNEE_DB_PROVIDER: postgres
      COGNEE_DB_HOST: ${POSTGRES_HOST:?Set POSTGRES_HOST in .env}
      COGNEE_DB_PORT: ${POSTGRES_PORT:-5432}
      COGNEE_DB_NAME: ${POSTGRES_DB:?Set POSTGRES_DB in .env}
      COGNEE_DB_USER: ${POSTGRES_USER:?Set POSTGRES_USER in .env}
      COGNEE_DB_PASSWORD: ${POSTGRES_PASSWORD:?Set POSTGRES_PASSWORD in .env}

      # Graph store - FalkorDB
      COGNEE_GRAPH_PROVIDER: falkordb
      COGNEE_GRAPH_HOST: falkordb
      COGNEE_GRAPH_PORT: 6379

      # Vector store - LanceDB (embedded)
      COGNEE_VECTOR_PROVIDER: lancedb
      COGNEE_VECTOR_PATH: /data/lancedb

      # LLM settings
      COGNEE_LLM_PROVIDER: ${LLM_PROVIDER:-openai}
      OPENAI_API_KEY: ${OPENAI_API_KEY:-}
    volumes:
      - cognee_data:/data
      - lancedb_data:/data/lancedb
    depends_on:
      falkordb:
        condition: service_healthy
    networks:
      - sonik-network

  # ============================================
  # NocoDB - Spreadsheet UI for PostgreSQL
  # ============================================
  nocodb:
    image: nocodb/nocodb:latest
    container_name: sonik-nocodb
    ports:
      - "8080:8080"
    environment:
      NC_DB: "pg://${POSTGRES_HOST}:${POSTGRES_PORT:-5432}?u=${POSTGRES_USER}&p=${POSTGRES_PASSWORD}&d=${POSTGRES_DB}"
      NC_AUTH_JWT_SECRET: ${NOCODB_JWT_SECRET:-change-me-in-production}
    volumes:
      - nocodb_data:/usr/app/data
    networks:
      - sonik-network

  # ============================================
  # Grist - Smart Spreadsheets
  # ============================================
  grist:
    image: gristlabs/grist:latest
    container_name: sonik-grist
    ports:
      - "8484:8484"
    environment:
      GRIST_SESSION_SECRET: ${GRIST_SESSION_SECRET:-change-me-in-production}
      GRIST_SINGLE_ORG: sonik
      APP_HOME_URL: http://localhost:8484
    volumes:
      - grist_data:/persist
    networks:
      - sonik-network

volumes:
  falkordb_data:
  redisvl_data:
  cognee_data:
  lancedb_data:
  nocodb_data:
  grist_data:

networks:
  sonik-network:
    driver: bridge
```

**Step 3: Create environment template**

```bash
# .env.cognee-stack
# Copy to .env and fill in YOUR database connection

# YOUR EXISTING PostgreSQL (Supabase, Autobase, etc.)
POSTGRES_HOST=your-postgres-host
POSTGRES_PORT=5432
POSTGRES_DB=your-database-name
POSTGRES_USER=your-username
POSTGRES_PASSWORD=your-password

# Redis (for RedisVL semantic cache)
REDIS_PASSWORD=your-redis-password

# NocoDB
NOCODB_JWT_SECRET=your-nocodb-jwt-secret

# Grist
GRIST_SESSION_SECRET=your-grist-session-secret

# LLM Provider (for Cognee)
LLM_PROVIDER=openai
OPENAI_API_KEY=your-openai-key
```

**Step 4: Commit**

```bash
git add sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml
git add sonik-os-orchestration/docker/.env.cognee-stack
git commit -m "infra: add Cognee stack Docker Compose (infrastructure only)"
```

---

## Task 2: Create Deployment Script

**Files:**
- Create: `sonik-os-orchestration/scripts/deploy-cognee-stack.sh`

**Step 1: Create scripts directory**

```bash
mkdir -p sonik-os-orchestration/scripts
```

**Step 2: Create deployment script**

```bash
#!/bin/bash
# deploy-cognee-stack.sh
# Deploy Cognee infrastructure (connects to your existing PostgreSQL)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$SCRIPT_DIR/../docker"

echo "=========================================="
echo "Sonik Cognee Stack Deployment"
echo "=========================================="

# Check for .env file
if [ ! -f "$DOCKER_DIR/.env" ]; then
    echo "ERROR: .env file not found!"
    echo ""
    echo "1. Copy the template:"
    echo "   cp $DOCKER_DIR/.env.cognee-stack $DOCKER_DIR/.env"
    echo ""
    echo "2. Fill in YOUR PostgreSQL connection details"
    echo ""
    exit 1
fi

cd "$DOCKER_DIR"

# Pull latest images
echo ""
echo "[1/3] Pulling latest images..."
docker-compose -f docker-compose.cognee-stack.yaml pull

# Start services
echo ""
echo "[2/3] Starting services..."
docker-compose -f docker-compose.cognee-stack.yaml up -d

# Wait and show status
echo ""
echo "[3/3] Waiting for services..."
sleep 10

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Services:"
echo "  FalkorDB:       localhost:6379  (graph database)"
echo "  RedisVL:        localhost:6380  (semantic cache)"
echo "  RedisInsight:   http://localhost:8001"
echo "  Cognee API:     http://localhost:8000"
echo "  NocoDB:         http://localhost:8080"
echo "  Grist:          http://localhost:8484"
echo ""
echo "PostgreSQL: Using YOUR external database (configured in .env)"
echo ""
docker-compose -f docker-compose.cognee-stack.yaml ps
```

**Step 3: Make executable**

```bash
chmod +x sonik-os-orchestration/scripts/deploy-cognee-stack.sh
```

**Step 4: Commit**

```bash
git add sonik-os-orchestration/scripts/deploy-cognee-stack.sh
git commit -m "infra: add Cognee stack deployment script"
```

---

## Task 3: Create Health Check Script

**Files:**
- Create: `sonik-os-orchestration/scripts/health-check.sh`

**Step 1: Create health check script**

```bash
#!/bin/bash
# health-check.sh
# Verify Cognee stack services

echo "Sonik Cognee Stack Health Check"
echo "================================"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_tcp() {
    local name=$1
    local port=$2
    if nc -z localhost "$port" 2>/dev/null; then
        echo -e "  $name: ${GREEN}OK${NC} (port $port)"
    else
        echo -e "  $name: ${RED}FAIL${NC} (port $port)"
    fi
}

check_http() {
    local name=$1
    local url=$2
    if curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "200\|301\|302"; then
        echo -e "  $name: ${GREEN}OK${NC}"
    else
        echo -e "  $name: ${RED}FAIL${NC}"
    fi
}

echo ""
echo "Infrastructure Services:"
check_tcp "FalkorDB" 6379
check_tcp "RedisVL" 6380

echo ""
echo "Application Services:"
check_http "Cognee API" "http://localhost:8000"
check_http "NocoDB" "http://localhost:8080"
check_http "Grist" "http://localhost:8484"
check_http "RedisInsight" "http://localhost:8001"

echo ""
echo "Container Status:"
docker ps --filter "name=sonik-" --format "table {{.Names}}\t{{.Status}}"
```

**Step 2: Make executable**

```bash
chmod +x sonik-os-orchestration/scripts/health-check.sh
```

**Step 3: Commit**

```bash
git add sonik-os-orchestration/scripts/health-check.sh
git commit -m "infra: add health check script"
```

---

## Task 4: Deploy Stack

**Step 1: Copy and configure .env**

```bash
cd sonik-os-orchestration/docker
cp .env.cognee-stack .env
```

**Step 2: Edit .env with YOUR PostgreSQL details**

Open `.env` and set:
- `POSTGRES_HOST` - Your database host (e.g., `db.xxxx.supabase.co` or `localhost`)
- `POSTGRES_PORT` - Usually `5432` (or `54322` for local Supabase)
- `POSTGRES_DB` - Your database name
- `POSTGRES_USER` - Your username
- `POSTGRES_PASSWORD` - Your password

Generate secrets for other services:
```bash
echo "REDIS_PASSWORD=$(openssl rand -base64 16)" >> .env
echo "NOCODB_JWT_SECRET=$(openssl rand -base64 24)" >> .env
echo "GRIST_SESSION_SECRET=$(openssl rand -base64 24)" >> .env
```

**Step 3: Deploy**

```bash
cd ../scripts
./deploy-cognee-stack.sh
```

**Step 4: Verify**

```bash
./health-check.sh
```

---

## Task 5: Verify Services

**Step 1: Check FalkorDB**

```bash
docker exec -it sonik-falkordb redis-cli PING
```
Expected: `PONG`

**Step 2: Check RedisVL**

```bash
docker exec -it sonik-redisvl redis-cli -a sonik PING
```
Expected: `PONG`

**Step 3: Open NocoDB**

Open http://localhost:8080 in browser. You should see NocoDB connected to your PostgreSQL.

**Step 4: Open Grist**

Open http://localhost:8484 in browser.

**Step 5: Check Cognee API**

```bash
curl http://localhost:8000/health
```

---

## Handoff Summary

### What This Plan Deploys

| Service | Port | Purpose |
|---------|------|---------|
| FalkorDB | 6379 | Graph database (OpenCypher) |
| RedisVL | 6380 | Semantic caching, vector search |
| RedisInsight | 8001 | Redis management UI |
| Cognee | 8000 | AI memory orchestration |
| NocoDB | 8080 | Spreadsheet UI for your PostgreSQL |
| Grist | 8484 | Smart spreadsheets |

### What This Plan Does NOT Do

- ❌ Create PostgreSQL instance (you have one)
- ❌ Create database schemas (handled by your migrations)
- ❌ Modify your existing data

### Quick Commands

```bash
# Deploy
./sonik-os-orchestration/scripts/deploy-cognee-stack.sh

# Check health
./sonik-os-orchestration/scripts/health-check.sh

# View logs
docker-compose -f sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml logs -f

# Stop
docker-compose -f sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml down

# Full reset (removes data)
docker-compose -f sonik-os-orchestration/docker/docker-compose.cognee-stack.yaml down -v
```

---

**Plan complete and saved to `docs/plans/2025-12-10-cognee-data-layer-deployment.md`.**

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks

**2. Parallel Session (separate)** - Open new session with executing-plans

**Which approach?**
