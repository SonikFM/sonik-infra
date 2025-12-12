# Sonik Unified Data Layer Architecture

**Date**: December 10, 2025
**Status**: Draft - Architectural Decisions Documented
**Linear Issues**: SON-375 (Schema), SON-376 (PG18 Migration - BLOCKING)

---

## Executive Summary

This document captures architectural decisions for Sonik's unified data layer, integrating:
- **PostgreSQL 18** (entities, transactions, ACID operations)
- **FalkorDB** (graph relationships, virality, attribution, knowledge)
- **LanceDB** (vector embeddings, semantic search)
- **RedisVL** (semantic caching)

The architecture supports Sonik's growth flywheel: SEO/content → traffic → free tools → data capture → Amplify (paid).

---

## Part 1: Business Context

### What Sonik Actually Is

**NOT** a financial transaction platform. Sonik is:

1. **Event Aggregation Platform**
   - Scrape concert/event data from multiple sources (local providers, Instagram, Resident Advisor)
   - Central source of truth for event discovery in LATAM markets
   - Post events for organizers who haven't claimed their accounts

2. **Lead Generation Engine**
   - Drive traffic to external ticket links (organizers host their own tickets)
   - Capture anonymous attribution stats (views → clicks → conversions)
   - Show unclaimed organizers: "We sent 847 clicks to your ticket page"
   - Convert unclaimed organizers into paying Amplify customers

3. **Content Marketing Platform**
   - SEO-optimized articles: "Best clubs in Medellin", "Things to do tonight in Quito"
   - LMO (LLM optimization) for ChatGPT/Perplexity visibility
   - Articles reference multiple entities (venues, events, artists)

### The Sonik Growth Flywheel

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CONTENT LAYER (SEO/LMO)                              │
│  • AI-generated articles: "Top clubs in Mexico City", "Bad Bunny concerts"   │
│  • All events posted (even if we don't sell tickets)                         │
│  • Human verification before publish                                         │
│  • Goal: Be everywhere, always → drive search traffic                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DISTRIBUTION LAYER (Social/Paid)                        │
│  • Local Instagram accounts (meme, news, influencer)                         │
│  • Semi-organic promotion of content                                         │
│  • Paid per click model for local media                                      │
│  • Goal: Drive traffic → capture engagement data                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PRODUCT LAYER (Free Tools)                             │
│  • RSVP/simplified event creation (Partyful-like)                           │
│  • Target: Anyone who wants to create/manage events                          │
│  • Seed events via targeted organizers/influencers                           │
│  • Goal: Low friction entry → identify active organizers                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CONVERSION LAYER (Amplify)                              │
│  • Marketing/advertising suite for event organizers                          │
│  • Proprietary data: virality graphs, attribution signals                    │
│  • Predictive analytics for events                                           │
│  • Goal: Free → Paid conversion via data value proposition                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 2: Data Philosophy

### Core Principles

1. **Data should be 3-dimensional, not flat**
   - Graph structure mirrors how humans think - concepts connected, traversable
   - Not just relationships, but **weighted** relationships
   - Edge weights increase with traversal frequency (path of least resistance)

2. **Separation of concerns by data nature**
   - **PostgreSQL**: Inherently linear data (transactions, rigid schemas, ACID)
   - **FalkorDB**: Inherently relational data (who knows who, influence paths)
   - **LanceDB**: Semantic similarity (embeddings, ANN search)
   - **RedisVL**: Hot path caching

3. **Source systems stay flexible, unified layer is strict**
   - Directus, Twenty CRM, MongoDB = flexible for staff operations
   - Supabase/FalkorDB = strict validation, deduplication, conflict prevention

4. **Same data, different lenses**
   - Graph traversal from different starting points = different business insights
   - Operations view, virality view, artist view, fan view = same graph, different queries

---

## Part 3: High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        SONIK DATA ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    POSTGRESQL 18 (Entities + Transactions)            │   │
│  │                                                                        │   │
│  │  • Master data: users, accounts, financial transactions               │   │
│  │  • Entity attributes (name, email, claim_status, metadata)           │   │
│  │  • External canonical IDs (google_places_id, instagram_url)          │   │
│  │  • ACID compliance for business-critical operations                   │   │
│  │  • pgvector for embeddings (semantic search)                         │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                          │                                                   │
│                          │ CDC (Debezium → n8n/Kafka)                       │
│                          ▼                                                   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    FALKORDB (Relationships + Graphs)                  │   │
│  │                                                                        │   │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐       │   │
│  │  │ operations      │  │ knowledge       │  │ agent_memory    │       │   │
│  │  │                 │  │                 │  │                 │       │   │
│  │  │ • Events        │  │ • Code/Features │  │ • Cognee KG     │       │   │
│  │  │ • Venues        │  │ • Feature flags │  │ • Session state │       │   │
│  │  │ • Virality      │  │ • Dependencies  │  │ • Context       │       │   │
│  │  │ • Attribution   │  │ • Impact→Revenue│  │ • Traversal log │       │   │
│  │  │ • Lead paths    │  │ • Sentiment     │  │ • Query weights │       │   │
│  │  │ • Entity rels   │  │ • Concepts      │  │ • Meta-learning │       │   │
│  │  └─────────────────┘  └─────────────────┘  └─────────────────┘       │   │
│  │                                                                        │   │
│  │  Edge Properties: weight (traversal frequency), timestamp, source     │   │
│  │  Cross-graph: Application-level orchestration (not native queries)    │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    LANCEDB (Vector Embeddings)                        │   │
│  │                                                                        │   │
│  │  • Semantic search across all content                                 │   │
│  │  • ANN (approximate nearest neighbor) for fast retrieval              │   │
│  │  • Bridge between graphs via vector similarity                        │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    REDISVL (Semantic Cache)                           │   │
│  │                                                                        │   │
│  │  • Cache frequent graph queries                                       │   │
│  │  • Semantic similarity for cache hits                                 │   │
│  │  • TTL-based invalidation                                             │   │
│  │  • Meta-learning: Track query frequency for optimization              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 4: FalkorDB Architecture Decisions

### Research Findings (December 2025)

| Feature | FalkorDB Capability |
|---------|---------------------|
| Multi-graph per instance | ✅ 10,000+ isolated graphs per instance |
| Graph isolation | ✅ Named graphs with complete data isolation |
| Cross-graph queries | ❌ NOT supported in single Cypher query |
| Multi-tenant ACL | ✅ Fine-grained permissions |
| GraphRAG SDK | ✅ Built-in for AI/LLM applications |
| Performance | ✅ Sub-10ms for millions of nodes |

### Named Graphs Decision

**Decision**: Three named graphs in single FalkorDB instance

| Graph Name | Purpose | Contents |
|------------|---------|----------|
| `operations` | Business operations, lead gen, virality | Events, venues, people, virality edges, attribution |
| `knowledge` | Code, features, business concepts | Code modules, features, feature flags, impact relationships |
| `agent_memory` | AI agent context, learning | Cognee KG, session state, traversal logs, query weights |

**Rationale**:
- Same FalkorDB instance = simpler ops, shared infrastructure
- Named graphs = logical isolation, different schemas
- Cross-graph queries via application-level orchestration (not Cypher)
- GraphRAG SDK can use different graphs for different agent specializations

### Platform vs Organizer Data

**Decision**: Same graph, different query perspectives

Platform virality tracking and organizer ad performance share:
- Same `Person` nodes (fans who spread word)
- Same `Event` nodes (what's being promoted)
- Same `SHARED`, `ATTENDED`, `PURCHASED` edges

Access control at application layer:
- Organizers see: Their events, their campaigns, their metrics
- Sonik sees: Everything (platform-wide patterns)

---

## Part 5: Graph Schema

### Vertex Types (Nodes)

```
CORE ENTITIES (synced from PostgreSQL)
├── Person        { id, name, canonical_id, claim_status, type }
├── Venue         { id, name, google_places_id, capacity, location }
├── Event         { id, name, date, genre, status }
├── Organization  { id, name, domain, type }
├── Artist        { id, name, instagram_url, genre }
└── Brand         { id, name, instagram_url }

OPERATIONAL ENTITIES
├── Campaign      { id, name, channel, budget, start_date, end_date }
├── Content       { id, type, title, url, published_at }
├── Market        { id, name, country, status }
└── Channel       { id, type, platform }  -- Instagram, paid, organic

KNOWLEDGE ENTITIES
├── Feature       { id, name, suite, status, revenue_impact }
├── FeatureFlag   { id, name, enabled, rollout_percentage }
├── CodeModule    { id, path, importance, dependencies_count }
└── Concept       { id, name, domain }  -- business concepts, terminology
```

### Edge Types (Relationships)

```
BUSINESS RELATIONSHIPS
├── OWNS           (Person)-[:OWNS]->(Venue|Organization|Brand)
├── MANAGES        (Person)-[:MANAGES]->(Artist|Venue)
├── PERFORMS_AT    (Artist)-[:PERFORMS_AT]->(Event)
├── HOSTED_BY      (Event)-[:HOSTED_BY]->(Venue)
├── PROMOTED_BY    (Event)-[:PROMOTED_BY]->(Organization)
└── WORKS_FOR      (Person)-[:WORKS_FOR]->(Organization)

ATTRIBUTION/VIRALITY (weighted edges)
├── SHARED         (Person)-[:SHARED {weight, timestamp, channel}]->(Event|Content)
├── ATTENDED       (Person)-[:ATTENDED {timestamp, ticket_tier}]->(Event)
├── PURCHASED      (Person)-[:PURCHASED {amount, timestamp, source}]->(Ticket)
├── REFERRED       (Person)-[:REFERRED {weight}]->(Person)
├── INFLUENCED     (Content)-[:INFLUENCED {weight}]->(Purchase)
└── CONVERTED_VIA  (Person)-[:CONVERTED_VIA]->(Campaign)

KNOWLEDGE RELATIONSHIPS
├── DEPENDS_ON     (CodeModule)-[:DEPENDS_ON {importance}]->(CodeModule)
├── IMPLEMENTS     (CodeModule)-[:IMPLEMENTS]->(Feature)
├── IMPACTS        (Feature)-[:IMPACTS {weight}]->(Revenue|Sentiment)
├── ENABLES        (FeatureFlag)-[:ENABLES]->(Feature)
└── RELATES_TO     (Concept)-[:RELATES_TO]->(Concept)

COMMON EDGE PROPERTIES (on all edges)
├── weight         -- traversal frequency / importance (0.0-1.0)
├── timestamp      -- when relationship was created/updated
├── source         -- where this data came from (scraper, CRM, manual)
└── confidence     -- certainty of relationship (for inferred edges)
```

---

## Part 6: External Canonical IDs

### Deduplication Strategy

**Decision**: Use external authoritative IDs as primary deduplication keys

| Entity Type | Canonical ID | Fallback |
|-------------|--------------|----------|
| Venues | Google Places ID | Supabase UUID |
| Organizations | Google Places ID or Domain | Supabase UUID |
| People/Artists | Instagram URL | Supabase UUID |
| Brands | Instagram URL or Domain | Supabase UUID |
| Events | Composite: venue_id + date + name hash | Supabase UUID |

**Why External IDs First**:
- Objective, globally unique, vendor-agnostic
- When scraper finds "XYZ Club" → lookup Google Places → instant dedup
- Same venue scraped from 5 sources → all resolve to same Places ID

### Entity Resolution Flow

```
Scraper finds "XYZ Club Medellin"
         │
         ▼
┌─────────────────────────────┐
│ Query Google Places API     │
│ Get place_id: ChIJN1t_tDeu  │
└─────────────────────────────┘
         │
         ▼
┌─────────────────────────────┐
│ Query PostgreSQL:           │
│ SELECT * FROM entities      │
│ WHERE google_places_id =    │
│ 'ChIJN1t_tDeu'              │
└─────────────────────────────┘
         │
         ├── EXISTS → Update existing entity
         │
         └── NOT EXISTS → Create new entity with UUID
```

---

## Part 7: Claim Status Funnel

### States

| Status | Description | Who Can Edit |
|--------|-------------|--------------|
| `unclaimed` | Discovered via scraping, no verified owner | Sonik staff only |
| `pending` | Claim request submitted, awaiting verification | Claimant (limited), Sonik staff |
| `claimed` | Verified owner, full access | Owner, Sonik staff |

### Transition Flow

```
          ┌─────────────┐
          │  SCRAPER    │
          │  discovers  │
          │  entity     │
          └──────┬──────┘
                 │
                 ▼
          ┌─────────────┐
          │  unclaimed  │ ←── Sonik staff can edit
          └──────┬──────┘     (curate, enrich, correct)
                 │
                 │ User submits claim
                 ▼
          ┌─────────────┐
          │  pending    │ ←── Verification required
          └──────┬──────┘     (Instagram DM, email, phone)
                 │
                 │ Sonik verifies
                 ▼
          ┌─────────────┐
          │  claimed    │ ←── Owner has full access
          └─────────────┘     (becomes paying customer potential)
```

---

## Part 8: Data Flow Architecture

### Source Systems

| System | Role | Data Types |
|--------|------|------------|
| Directus | CMS, content staging | Events, venues, articles, scrape jobs |
| Twenty CRM | Lead/sales pipeline | Companies, people, opportunities |
| Sonik MongoDB | Operational records | User accounts, transactions, tickets |
| Web Scrapers (n8n) | Data discovery | Event listings, venue info, artist profiles |

### Sync Pattern

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA FLOW                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   Web Scrapers (n8n/Apify)                                                   │
│         │                                                                    │
│         ▼                                                                    │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐                       │
│   │  Directus   │   │ Twenty CRM  │   │  MongoDB    │                       │
│   │  (staging)  │   │  (leads)    │   │  (ops)      │                       │
│   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘                       │
│          │                 │                 │                               │
│          └────────────┬────┴─────────────────┘                               │
│                       │                                                      │
│                       ▼ CDC (Debezium/n8n webhooks)                         │
│                       │                                                      │
│   ┌───────────────────┴───────────────────┐                                 │
│   │         POSTGRESQL 18                  │                                 │
│   │  (unified entities, transactions)      │                                 │
│   │  • Validation & deduplication          │                                 │
│   │  • External ID resolution              │                                 │
│   │  • Conflict prevention                 │                                 │
│   └───────────────────┬───────────────────┘                                 │
│                       │                                                      │
│                       ▼ CDC (entity changes)                                │
│                       │                                                      │
│   ┌───────────────────┴───────────────────┐                                 │
│   │          FALKORDB                      │                                 │
│   │  (operations, knowledge, agent_memory) │                                 │
│   │  • Relationship creation               │                                 │
│   │  • Edge weight updates                 │                                 │
│   │  • Graph traversal queries             │                                 │
│   └───────────────────────────────────────┘                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Part 9: Meta-Learning Concept (Future)

### Path of Least Resistance

**Concept**: Track query/traversal frequency to identify patterns

Like the streets of Boston (cow paths became roads), frequently traversed graph paths indicate:
- Important relationships
- Common workflows
- Potential optimizations
- Blockers (if agents keep hitting same dead ends)

### Implementation Ideas

1. **Edge weight accumulation**: Each traversal increments edge weight
2. **Query logging in RedisVL**: Track which queries fire most often
3. **Agent traversal monitoring**: Log when agents hit blockers
4. **Anomaly detection**: Paths "burning too hot" = potential issue

**Not implementing now** - documented for future consideration.

---

## Part 10: Open Questions

### Immediate (Blocking PG18)

1. **Directus schema fields**: Which fields need to be finalized before migration?
2. **Supabase migration state**: What's currently deployed vs proposed?
3. **FalkorDB integration**: How does Cognee currently use FalkorDB?

### Near-term

1. **Google Places API**: Integration for canonical ID resolution
2. **Instagram URL normalization**: Handle @user, /user/, full URL variations
3. **CDC implementation**: Debezium vs n8n webhooks for Postgres → FalkorDB

### Future

1. **Cross-graph queries**: Application-level orchestration patterns
2. **Meta-learning**: Query frequency tracking and optimization
3. **Feature attribution**: Tying code changes to revenue impact

---

## Part 11: Blockers

| Blocker | Issue | Status |
|---------|-------|--------|
| PG18 Migration | SON-376 | **BLOCKING** - Must complete before schema updates |
| Supabase Schema | SON-375 | Waiting on PG18 |
| Amplify Integration | - | Waiting on attribution architecture |

---

## Appendix A: Research Sources

### FalkorDB Capabilities
- FalkorDB supports 10,000+ isolated graphs per instance
- Multi-graph querying supported via APIs (not single Cypher query)
- GraphRAG SDK for AI applications
- Sub-10ms performance for millions of nodes
- Source: FalkorDB documentation, December 2025

### Hybrid Architecture Best Practices
- PostgreSQL for entities, Graph DB for relationships is emerging pattern
- CDC (Debezium → Kafka) is most reliable sync pattern
- Avoid dual writes - use event sourcing or CDC
- Source: Industry research, December 2025

### Graph + Vector Hybrid
- LanceDB for ANN search, FalkorDB for relationships
- Hybrid RAG: vector retrieval → graph traversal → LLM
- 90% hallucination reduction with graph-grounded RAG
- Source: FalkorDB GraphRAG SDK documentation

---

*Document generated: December 10, 2025*
*Status: Draft - pending schema validation against migrations*
