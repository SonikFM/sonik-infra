# Sonik Infrastructure - Handoff Prompt

**Date:** 2025-12-10
**Status:** Ready for AWS deployment
**Repo:** `sonik-infra` (committed, needs GitHub remote)

---

## Copy This to New Chat

```
I need to deploy the Sonik Cognee stack to AWS.

## Context

The `sonik-infra` repo has been set up with:
- Docker Compose for Cognee stack (FalkorDB, RedisVL, Cognee, NocoDB, Grist)
- Deploy and health check scripts
- Environment template

Read these files to understand the setup:
1. `/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra/README.md`
2. `/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra/docs/2025-12-10-SONIK-INFRASTRUCTURE-HANDOFF.md`

## AWS Instance

- **IP:** 18.191.215.116
- **User:** ubuntu
- **SSH Key:** `sonik-os.pem` (in sonik-os root)

## What Needs to Happen

### Phase 1: Push to GitHub (5 min)
1. Create GitHub repo `sonik-infra` under sonik-dev org
2. Add remote and push

### Phase 2: Deploy to AWS (30 min)
1. SSH into instance
2. Install Docker + Docker Compose
3. Clone repo
4. Configure .env with Supabase credentials
5. Run deploy script
6. Verify with health check

## Supabase Connection

- **Host:** db.jjdofmqlgsfgmdvnuakv.supabase.co
- **Port:** 5432
- **Database:** postgres
- **User:** postgres
- **Password:** [Get from Supabase dashboard or ask user]

## Services & Ports

| Service | Port | Purpose |
|---------|------|---------|
| FalkorDB | 6379 | Graph database (OpenCypher) |
| RedisVL | 6380 | Semantic caching |
| RedisInsight | 8001 | Redis management UI |
| Cognee | 8000 | AI memory orchestration |
| NocoDB | 8080 | Spreadsheet UI |
| Grist | 8484 | Smart spreadsheets |

## Priority

GET IT LIVE - don't over-engineer. Start with Phase 1 (GitHub push).
```

---

## Quick SSH Command

```bash
ssh -i /Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
```

## Local Repo Path

```
/Users/danielletterio/Documents/GitHub/sonik-dev/sonik-os/sonik-infra
```
