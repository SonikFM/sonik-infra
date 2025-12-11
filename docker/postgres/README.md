# Sonik PostgreSQL 18 + pgvector

Local development database with all Sonik migrations.

## Quick Start

```bash
cd docker/postgres
cp .env.example .env
# Edit .env with your password
docker compose up -d
```

## Connection Details

- **Host:** localhost
- **Port:** 5432
- **User:** sonik
- **Password:** (from .env)
- **Database:** sonik_db

**Connection String:**
```
postgresql://sonik:your_password@localhost:5432/sonik_db
```

## Migrations

All 30 migrations run automatically on first boot:

**Baseline Schema (001-026):**
- 001: Enable extensions (uuid-ossp, pgcrypto, vector)
- 002: Create uuidv7 function
- 003: Create schemas (shared, market, finance, content, metadata)
- 004-026: Core tables for currencies, countries, users, organizations, events, tickets, revenue, sponsors, and embeddings

**New Schema Updates (027-030):**
- 027: `claim_status` enum migration
- 028: Canonical IDs for ownership verification
- 029: `content.events` first-class entity
- 030: `finance.events` FK to `content.events`

## Commands

### Start Database
```bash
docker compose up -d
```

### Stop Database
```bash
docker compose down
```

### View Logs
```bash
docker compose logs -f postgres
```

### Connect via psql
```bash
docker exec -it sonik-postgres psql -U sonik -d sonik_db
```

### Reset Database (Destroy Data)
```bash
docker compose down -v
docker compose up -d
```

### Check Health Status
```bash
docker compose ps
```

### Verify Migrations
```bash
# List all tables
docker exec sonik-postgres psql -U sonik -d sonik_db -c "\dt *.*"

# Count tables per schema
docker exec sonik-postgres psql -U sonik -d sonik_db -c "
SELECT schemaname, COUNT(*)
FROM pg_tables
WHERE schemaname IN ('shared', 'market', 'finance', 'content', 'metadata')
GROUP BY schemaname
ORDER BY schemaname;"
```

## Extensions

- **pgvector 0.8.0**: Vector similarity search for RAG

Verify extension:
```bash
docker exec sonik-postgres psql -U sonik -d sonik_db -c "SELECT extname, extversion FROM pg_extension WHERE extname = 'vector';"
```

## Troubleshooting

### Container won't start
- Check if port 5432 is already in use: `lsof -i :5432`
- View container logs: `docker compose logs postgres`

### Migrations didn't run
- Ensure this is the first boot with fresh volumes
- Migrations only run once on initialization
- To re-run: `docker compose down -v && docker compose up -d`

### Can't connect from host
- Verify container is healthy: `docker compose ps`
- Check password in `.env` matches connection string
- Ensure container is listening: `docker exec sonik-postgres pg_isready -U sonik`

## Development Notes

- Data persists in Docker volume `postgres_data`
- Volume survives container restarts (`docker compose down`)
- Volume deleted with `-v` flag (`docker compose down -v`)
- Migrations are read-only in container
- Default password for dev: `sonik_dev_password` (change in production)
