# Brainstorm Decisions - December 10, 2025

**Session**: Unified Data Layer Architecture Brainstorming
**Status**: RECORDED FOR NEXT SESSION

---

## Decision 1: Event Types (4 Categories)

**CONFIRMED**: Events are NOT binary (ticketed vs discovery). There are **4 types**:

| Type | Ticketed | Visibility | Example |
|------|----------|------------|---------|
| **Ticketed Public** | Yes | Public | Regular concert |
| **Ticketed Private** | Yes | Private/Invite | Exclusive event |
| **Non-Ticketed Private** | No | Private/Invite | RSVP event |
| **Discovery Event** | No | Public | Scraped/aggregated event |

**Implementation**: Need `is_ticketed` boolean + `visibility` enum (`public`, `private`)

---

## Decision 2: Claim Status (Enum, NOT Boolean)

**CONFIRMED**: Change from boolean to enum

**Approved statuses**:
- `unclaimed` - Discovered, no owner
- `pending` - Claim submitted, awaiting verification
- `claimed` - Verified owner

**Possible additions**:
- `restricted` - Limited access for some reason
- `banned` - Banned from Sonik platform

**Action**: Replace `is_claimed: BOOLEAN` with `claim_status: TEXT CHECK (claim_status IN ('unclaimed', 'pending', 'claimed', 'restricted', 'banned'))`

---

## Decision 3: Canonical IDs (PARTIALLY RESOLVED)

**STATUS**: Primary decision made, research needed for best practices

**CONFIRMED (Dec 10 Session 2)**:
- **Venues**: Google Places ID is PRIMARY. Instagram URL is FALLBACK if no Google Places ID.
- **Rule**: Must have at least one (Google Places ID OR Instagram URL). If neither exists, don't scrape.
- **Purpose**: Ownership verification (NOT deduplication). Pass attribution/metadata to verified owner.

**Organizations**:
- Can own multiple venues
- Can have events not attached to venues
- Deduplication handled separately (acceptable to dedupe a few records manually)

**Research Still Needed**:
- How do Bandsintown, Spotify, Google, Instagram, Twitter handle canonical IDs?
- Best practices for artist/performer identification (Spotify ID? MusicBrainz?)

**Action**: Research agent dispatched for platform comparison

---

## Decision 4: Event Architecture (RESEARCH IN PROGRESS)

**STATUS**: Key decisions made, research needed for implementation pattern

**CONFIRMED (Dec 10 Session 2)**:
- **Organizer IS a first-class entity** - definite yes
- **Events likely single table** - all 4 types in one table, differentiated by attributes (`is_ticketed`, `visibility`)
- **Events live in MongoDB operational DB** - Supabase is for relationships/analytics, not operational data
- **UUIDs required** - Events can change type (discovery → ticketed), need stable ID for time-series tracking

**Event Lifecycle**:
1. **Scraped event** → `unclaimed`, `discovery` type (non-ticketed public)
2. **Organizer claims** → becomes `claimed`, stays non-ticketed public OR upgrades to ticketed
3. **Mid-stream adoption** → organizer can switch discovery → ticketed event (time-series tracks this)

**Business Model Insight**:
- Sonik can post events without permission (like a magazine writing articles)
- Show meaningful traffic → warm open for sales approach
- Attribution data transfers to organizer when they claim

**Ticketing Rules**:
- Only **organizations** can sell tickets
- **Individuals** can create RSVP events (non-ticketed)
- When RSVP releases, person becomes "person" not "organization"

**Research Needed**:
- How do Posh, Resident Advisor, Eventbrite model events?
- Single table vs multiple tables pattern comparison

**Action**: Research agent dispatched for platform comparison

---

## Decision 5: Google Places ID for Venues

**CONFIRMED**: Add `google_places_id` field for venue deduplication

**Action**: Add to `market.entities` and `market.organizations` where `entity_type = 'venue'`

---

## Decision 6: Attribution Tables

**STATUS**: PENDING - User needs time to think through

**Reason**: Attribution is an Amplify feature that requires more thought

**Action**: Do NOT implement attribution tables yet. Wait for user direction.

---

## Summary: What to Implement NOW vs LATER

### Implement NOW (Pre-PG18):
1. ✅ Change `is_claimed` to `claim_status` enum
2. ✅ Add `google_places_id` field to entities/organizations

### PAUSED (Needs Discussion):
3. ⏸️ Event architecture (single table vs multiple, 4-type model)
4. ⏸️ Canonical ID research (Google Places vs Instagram vs both)

### PENDING (User Decision Required):
5. ⏳ Attribution tables (Amplify feature - user thinking)

---

## Files Created This Session

| File | Purpose |
|------|---------|
| `docs/plans/2025-12-10-unified-data-layer-architecture.md` | Architecture vision document |
| `docs/schemas/UNIFIED-SCHEMA-REFERENCE.md` | Compiled schema from 26 migrations |
| `docs/schemas/SCHEMA-ERD.md` | Machine-readable ERD |
| `docs/schemas/SCHEMA-GAP-ANALYSIS.md` | Gap analysis vs architecture |
| `docs/plans/2025-12-10-brainstorm-decisions.md` | THIS FILE - Decision record |

---

## Linear Issues

- **SON-375**: Complete Supabase schema updates
- **SON-376**: Create PG18 database (BLOCKING)

---

## Next Session Prompt

```
Continue unified data layer architecture work. Read these files first:
1. docs/plans/2025-12-10-unified-data-layer-architecture.md
2. docs/plans/2025-12-10-brainstorm-decisions.md
3. docs/schemas/SCHEMA-GAP-ANALYSIS.md

Key decisions to make:
1. Event architecture: Should events be one table with 4 types, or multiple tables?
2. Canonical ID research: Best practice for venue verification
3. Attribution: When ready to discuss Amplify attribution features

Approved changes to implement:
1. Change is_claimed boolean to claim_status enum
2. Add google_places_id for venue deduplication
```

---

*Recorded: 2025-12-10*
