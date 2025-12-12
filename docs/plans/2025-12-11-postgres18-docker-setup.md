# PostgreSQL 18 + pgvector Docker Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a local Docker-based PostgreSQL 18 database with pgvector extension and all 30 Sonik migrations, version-controlled for GitHub backup.

**Architecture:** Docker Compose defines PG18 container with pgvector image. Init script runs migrations in order on first boot. Volume persists data locally. GitHub stores migrations as backup for AWS deployment later.

**Tech Stack:** Docker, PostgreSQL 18, pgvector 0.8.0, shell scripts

---

## Task 1: Create Docker Directory Structure

**Files:**
- Create: `docker/postgres/docker-compose.yml`
- Create: `docker/postgres/migrations/` (directory)
- Create: `docker/postgres/init/00-init.sh`

**Step 1: Create directory structure**

```bash
mkdir -p docker/postgres/migrations
mkdir -p docker/postgres/init
```

**Step 2: Verify directories exist**

Run: `ls -la docker/postgres/`
Expected: `migrations/` and `init/` directories

**Step 3: Commit**

```bash
git add docker/postgres/
git commit -m "chore: create postgres docker directory structure"
```

---

## Task 2: Create Docker Compose Configuration

**Files:**
- Create: `docker/postgres/docker-compose.yml`

**Step 1: Write docker-compose.yml**

```yaml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg18
    container_name: sonik-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: sonik
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-sonik_dev_password}
      POSTGRES_DB: sonik_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d/migrations:ro
      - ./init:/docker-entrypoint-initdb.d/init:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sonik -d sonik_db"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
    driver: local
```

**Step 2: Verify file syntax**

Run: `docker compose -f docker/postgres/docker-compose.yml config`
Expected: Valid YAML output without errors

**Step 3: Commit**

```bash
git add docker/postgres/docker-compose.yml
git commit -m "feat: add postgres 18 docker-compose with pgvector"
```

---

## Task 3: Create Initialization Script

**Files:**
- Create: `docker/postgres/init/00-init.sh`

**Step 1: Write init script**

```bash
#!/bin/bash
set -e

echo "=== Sonik PostgreSQL Initialization ==="
echo "Running migrations..."

# Run migrations in order
for migration in /docker-entrypoint-initdb.d/migrations/*.sql; do
    if [ -f "$migration" ]; then
        echo "Running: $(basename $migration)"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$migration"
    fi
done

echo "=== All migrations complete ==="
```

**Step 2: Make script executable**

Run: `chmod +x docker/postgres/init/00-init.sh`

**Step 3: Verify script is executable**

Run: `ls -la docker/postgres/init/00-init.sh`
Expected: `-rwxr-xr-x` permissions

**Step 4: Commit**

```bash
git add docker/postgres/init/00-init.sh
git commit -m "feat: add postgres init script for migrations"
```

---

## Task 4: Copy Baseline Migrations (001-026)

**Files:**
- Copy: All `2024120800*.sql` files from `supabase/migrations/` to `docker/postgres/migrations/`

**Step 1: Copy baseline migrations**

```bash
cp supabase/migrations/2024120800*.sql docker/postgres/migrations/
```

**Step 2: Verify 26 baseline files copied**

Run: `ls docker/postgres/migrations/2024120800*.sql | wc -l`
Expected: `26`

**Step 3: Commit**

```bash
git add docker/postgres/migrations/2024120800*.sql
git commit -m "feat: add 26 baseline migrations to docker postgres"
```

---

## Task 5: Copy New Schema Migrations (027-030)

**Files:**
- Copy: All `20241210*.sql` files from `supabase/migrations/` to `docker/postgres/migrations/`

**Step 1: Copy new migrations**

```bash
cp supabase/migrations/20241210*.sql docker/postgres/migrations/
```

**Step 2: Verify 4 new files copied**

Run: `ls docker/postgres/migrations/20241210*.sql | wc -l`
Expected: `4`

**Step 3: Verify total migration count**

Run: `ls docker/postgres/migrations/*.sql | wc -l`
Expected: `30`

**Step 4: Commit**

```bash
git add docker/postgres/migrations/20241210*.sql
git commit -m "feat: add 4 new schema migrations (claim_status, canonical_ids, content_events, finance_events_fk)"
```

---

## Task 6: Create Environment Template

**Files:**
- Create: `docker/postgres/.env.example`

**Step 1: Write environment template**

```bash
# PostgreSQL Configuration
POSTGRES_PASSWORD=your_secure_password_here

# For production, use a strong password:
# openssl rand -base64 32
```

**Step 2: Commit**

```bash
git add docker/postgres/.env.example
git commit -m "docs: add postgres environment template"
```

---

## Task 7: Create README for Docker Postgres

**Files:**
- Create: `docker/postgres/README.md`

**Step 1: Write README**

```markdown
# Sonik PostgreSQL 18 + pgvector

Local development database with all Sonik migrations.

## Quick Start

```bash
cd docker/postgres
cp .env.example .env
# Edit .env with your password
docker compose up -d
```

## Connection

- **Host:** localhost
- **Port:** 5432
- **User:** sonik
- **Password:** (from .env)
- **Database:** sonik_db

## Migrations

All 30 migrations run automatically on first boot:
- 001-026: Baseline schema (shared, market, finance, metadata)
- 027: claim_status enum migration
- 028: canonical IDs for ownership verification
- 029: content.events first-class entity
- 030: finance.events FK to content.events

## Commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f postgres

# Connect via psql
docker exec -it sonik-postgres psql -U sonik -d sonik_db

# Reset (destroy data)
docker compose down -v
docker compose up -d
```

## Extensions

- **pgvector 0.8.0**: Vector similarity search for RAG
```

**Step 2: Commit**

```bash
git add docker/postgres/README.md
git commit -m "docs: add postgres docker README with usage instructions"
```

---

## Task 8: Test Docker Setup Locally

**Files:**
- None (validation only)

**Step 1: Start the container**

Run: `cd docker/postgres && docker compose up -d`
Expected: Container starts without errors

**Step 2: Wait for healthcheck**

Run: `docker compose ps`
Expected: `sonik-postgres` shows `healthy` status (may take 30 seconds)

**Step 3: Verify migrations ran**

Run: `docker exec sonik-postgres psql -U sonik -d sonik_db -c "\dt *.*" | head -30`
Expected: Tables from shared, market, finance, content, metadata schemas

**Step 4: Verify pgvector extension**

Run: `docker exec sonik-postgres psql -U sonik -d sonik_db -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"`
Expected: `vector | 0.8.0` (or similar)

**Step 5: Verify content.events table exists**

Run: `docker exec sonik-postgres psql -U sonik -d sonik_db -c "\d content.events"`
Expected: Table definition with event_category, visibility, is_ticketed columns

**Step 6: Stop container (optional)**

Run: `docker compose down`

---

## Task 9: Push to GitHub

**Files:**
- None (git operations only)

**Step 1: Verify all changes staged**

Run: `git status`
Expected: All docker/postgres/ files committed

**Step 2: Push to remote**

Run: `git push origin feature/schema-updates-dec10`
Expected: Push succeeds

---

## Summary

After completing all tasks:

| Component | Status |
|-----------|--------|
| Docker Compose | PostgreSQL 18 + pgvector |
| Migrations | 30 total (26 baseline + 4 new) |
| Init Script | Runs migrations on first boot |
| Documentation | README with usage instructions |
| GitHub | Backed up for AWS deployment |

**Next Steps (AWS Deployment):**
1. SSH to EC2 instance
2. Clone sonik-infra repo
3. Run `docker compose up -d` in docker/postgres/
4. Or use AutoBase Console for HA cluster deployment
