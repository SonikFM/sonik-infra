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
- **FalkorDB**: Already running on port 6379 (Redis protocol, OpenCypher queries)
- Supabase: jjdofmqlgsfgmdvnuakv (needs PG18 migration)
- Linear: sonik-infra project with SON-375 (schema) and SON-376 (PG18)

### Credential Location
```bash
ssh -i ~/Documents/GitHub/sonik-dev/sonik-os/sonik-os.pem ubuntu@18.191.215.116
cat ~/sonik-infra/docker/.env
```

## Schema Design Decisions

### 1. Graph Database: FalkorDB (DEPLOYED)
FalkorDB is live on the Cognee stack. It serves **dual purposes** that need to be evaluated:

| Use Case | Purpose | Current Status |
|----------|---------|----------------|
| **Agent Memory** | Cognee knowledge graphs, AI context | Deployed via Cognee |
| **Business Graph** | Virality, attribution, lead gen | NOT YET DESIGNED |

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

## Strategic Questions to Answer

### Agent Memory vs Business Graph

FalkorDB currently powers Cognee's agent memory (knowledge graphs for AI context). But the business case for a graph database extends far beyond AI:

1. **Separation or Shared?**
   - Should agent memory and business graph live in the same FalkorDB instance?
   - What are the isolation requirements? (AI can't corrupt business data)
   - Performance implications of shared vs separate?

2. **Business Graph Use Cases**
   - **Virality tracking**: How does content spread? Who influences whom?
   - **Attribution**: Which touchpoints led to conversion? Multi-touch paths?
   - **Lead generation**: Who's connected to who? Warm intro paths?
   - **Event discovery**: Artist → Venue → Promoter → Fan relationships

3. **Graph Schema for Business**
   - What are the core vertices? (Person, Venue, Event, Organization, Content)
   - What are the edges? (PERFORMS_AT, PROMOTES, ATTENDED, SHARED, FOLLOWS)
   - What properties on edges? (timestamp, weight, attribution_source)

4. **Data Flow Architecture**
   - How does scraped data (Directus) become graph nodes?
   - How does CRM data (Twenty) sync to graph?
   - Real-time vs batch ingestion?

5. **Query Patterns for Business**
   - "Show me the shortest path from Fan A to Artist B" (warm intro)
   - "What events did people who attended Event X also attend?" (virality)
   - "Which promoters have the highest conversion rate?" (attribution)

### PostgreSQL 18 Migration (BLOCKING)

**This must be completed first.** Current Supabase instance has compatibility issues blocking schema updates.

| Task | Status | Blocker |
|------|--------|---------|
| Create PG18 project in Supabase | TODO | None |
| Migrate data from current DB | TODO | PG18 project |
| Update .env on AWS | TODO | Data migration |
| Validate all services | TODO | .env update |

**Linear Issue**: SON-376

## Files to Read

- `docs/SCHEMA-IMPLEMENTATION-HANDOFF.md` - Previous field mappings
- `docs/linear/03-cognee-stack-services.md` - FalkorDB details (port 6379)
- Cognee documentation on FalkorDB usage

## Tasks

1. **Complete PG18 migration** (SON-376) - BLOCKING
2. Complete Supabase schema updates (SON-375)
3. Design business graph schema for FalkorDB
4. Define data flow: Directus/Twenty → FalkorDB
5. Evaluate agent memory vs business graph separation

## Linear Issues

- **SON-375**: Complete Supabase schema updates
- **SON-376**: Create PG18 database to complete database updates (BLOCKING)

## FalkorDB Access

```bash
# Connect to FalkorDB (Redis protocol)
redis-cli -h 18.191.215.116 -p 6379

# Run Cypher query
GRAPH.QUERY cognee "MATCH (n) RETURN n LIMIT 10"
```

---

*Generated: 2025-12-10*
*Updated: FalkorDB (not Apache AGE), added business graph questions*
