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
