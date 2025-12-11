# Schema & Graph Database Handoff

## Context

You are continuing schema design work for Sonik. The previous session clarified critical business context:

**CRITICAL CORRECTION**: Sonik is an **EVENT AGGREGATION PLATFORM**, not a financial transaction system.
- `directus.events` = scraped discovery data (venues, times, artists)
- These are NOT financial events or transactions
- Think: "What's happening tonight?" not "Payment processed"

## Current State

### Infrastructure Ready
- AWS: 18.191.215.116 with Cognee stack deployed
- Supabase: jjdofmqlgsfgmdvnuakv (needs PG18 migration)
- Linear: sonik-infra project with SON-375 (schema) and SON-376 (PG18)

### Credential Location
```bash
ssh -i ~/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
cat ~/sonik-infra/docker/.env
```

## Schema Design Decisions

### 1. Graph Database: Apache AGE
Selected for graph relationships within PostgreSQL/Supabase. Enables:
- Person ↔ Venue ↔ Organization connections
- "Who plays where" and "Who promotes what" queries
- Native PostgreSQL integration (no separate service)

### 2. External Canonical IDs
Deduplication via authoritative external sources:

| Entity | Canonical ID | Example |
|--------|-------------|---------|
| Venue | Google Places ID | `ChIJN1t_tDeu...` |
| Artist | Instagram URL | `instagram.com/artist` |
| Organization | Domain | `sonik.fm` |

### 3. Unified Entity Model

```
┌─────────────────────────────────────────────────────────────┐
│                    unified.entities                         │
├─────────────────────────────────────────────────────────────┤
│ id (uuid)                                                   │
│ entity_type: 'person' | 'venue' | 'organization'           │
│ canonical_id: external authoritative ID                     │
│ claim_status: 'unclaimed' | 'pending' | 'claimed'          │
│ claimed_by: user_id (nullable)                             │
│ metadata: jsonb (flexible attributes)                       │
└─────────────────────────────────────────────────────────────┘
```

### 4. Claim Status Funnel
- **Unclaimed**: Discovered via scraping, no owner
- **Pending**: Claim request submitted, awaiting verification
- **Claimed**: Verified owner, can edit

## Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-1 | Deduplicate entities using external canonical IDs |
| FR-2 | Support anonymous → known user attribution |
| FR-3 | Enable claim workflow for discovered entities |
| FR-4 | Graph queries: "artists at venue X", "venues by promoter Y" |
| FR-5 | Mirror Directus/Twenty data without breaking existing systems |
| FR-6 | Event aggregation queries (what's happening when/where) |
| FR-7 | Lead generation from anonymous engagement |

## Source Systems to Integrate

### Directus (Event Discovery)
- `events`: Scraped event data (name, date, venue, artists)
- `venues`: Location data from scraping
- `artists`: Performer profiles

### Twenty CRM
- `people`: Contact records
- `companies`: Business entities
- `opportunities`: Sales pipeline

## Questions to Investigate

1. **Apache AGE Setup**: How to enable in Supabase? Extension available?
2. **Graph Schema**: What vertices and edges for event aggregation?
3. **Migration Path**: How to populate graph from existing Directus/Twenty data?
4. **Query Patterns**: Cypher queries for common use cases?
5. **Performance**: Index strategy for graph + relational hybrid?

## Files to Read

- `docs/SCHEMA-IMPLEMENTATION-HANDOFF.md` - Previous field mappings
- `docs/plans/2025-12-09-graph-database-unified-schema.md` - If exists
- `docs/research/` - Any graph DB research

## Task

1. Research Apache AGE compatibility with Supabase
2. Design graph schema (vertices, edges, properties)
3. Create migration plan from current schema
4. Update Linear issues SON-375 and SON-376 with findings
5. If AGE not viable, evaluate alternatives (FalkorDB already deployed)

## Linear Issues

- **SON-375**: Complete Supabase schema updates
- **SON-376**: Create PG18 database to complete database updates

---

*Generated: 2025-12-10*
