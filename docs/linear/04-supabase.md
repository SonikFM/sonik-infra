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
