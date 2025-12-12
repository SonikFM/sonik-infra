# Event Architecture Patterns Research

**Date**: 2025-12-10
**Context**: Sonik Event Discovery & Ticketing Platform
**Goal**: Design unified event schema supporting 4 event types in MongoDB + Supabase

---

## Executive Summary

After researching Posh, Resident Advisor, Eventbrite, and Dice.fm, plus industry best practices, the **recommended approach is a single polymorphic events table** using the Single Table Inheritance (STI) pattern with attribute-based differentiation. This aligns with Sonik's existing Supabase schema in `finance.events` and supports mid-lifecycle type transitions.

**Key Finding**: All researched platforms appear to use a unified events table with type discriminators, not separate tables per event type.

---

## Sonik Event Types

| Event Type | Description | Ticketing | Access Control |
|------------|-------------|-----------|----------------|
| **Ticketed Public** | Regular concerts, festivals | Paid tickets | Public listing |
| **Ticketed Private** | Exclusive events | Paid + invite list | Invite-only visibility |
| **Non-Ticketed Private** | RSVP events | Free with guest list | Invite-only visibility |
| **Discovery Event** | Scraped/aggregated events | No ticketing (read-only) | Public listing |

**Critical Requirements**:
- Events can transition between types (e.g., Discovery → Ticketed Public)
- Only organizations can sell tickets (not individuals)
- Individuals can create Non-Ticketed Private RSVP events
- Organizer is a first-class entity (separate from venue)

---

## Platform Research Findings

### 1. Posh.vip

**Platform Type**: Social events platform ("TikTok for small events")
**Scale**: 2M+ users, $95M in ticket sales
**Founded**: 2019, Series A funded ($27M)

#### Key Features
- White-labeled event pages
- Promoter management system
- Demand-based dynamic ticket pricing
- SMS segmentation and attendee targeting
- Instagram linked guestlist
- AI-controlled ticket tiers
- Waiting list for sold-out shows
- Ticket transfers and resales through waiting list

#### Inferred Architecture
- Mobile-first platform
- Real-time analytics dashboard
- Event performance tracking
- Likely uses a **single events table** with status/type fields to support both intimate dinners and large festivals
- Promoter is a first-class entity with management system

**Relevance to Sonik**:
- Similar scale and use case (small to large events)
- Promoter management validates our organization-first model
- Dynamic pricing suggests flexible ticket tier structure
- Waiting list = event state transitions

**Sources**:
- [Event platform POSH wants to democratize event planning | TechCrunch](https://techcrunch.com/2023/04/27/event-management-ticketing-platform-posh-raises-5-million-seed-round/)
- [How Does POSH Company Work? | CanvasBusinessModel](https://canvasbusinessmodel.com/blogs/how-it-works/posh-how-it-works)
- [Explore your Event Analytics | Posh Knowledge Base](https://support.posh.vip/en/articles/10723755-explore-your-event-analytics)

---

### 2. Resident Advisor (RA)

**Platform Type**: Electronic music events discovery + ticketing
**Scale**: Industry-leading events listings globally

#### Key Features
- All tickets barcoded with QR codes
- RA Ticket Scanner app for fast entry
- Resale service for sold-out events
- Promo codes for discounted tickets
- Hidden ticket tiers (invite-only, pre-registration)
- Advanced reporting (sales sources, finance reports)
- BrainTree payment processing
- 28 global currencies, 100% PCI compliant
- Data insight tools for audience understanding

#### Inferred Architecture
- **Hidden ticket tiers** = attribute-based visibility control (NOT separate tables)
- Promo codes suggest flexible pricing structures within single event entity
- Resale marketplace implies event state machine with sold_out → resale transitions
- Data-driven approach = embeddings and analytics on unified event data

**Relevance to Sonik**:
- Hidden tiers validate our `is_visible` approach in ticket_tiers
- Multi-currency support aligns with existing schema
- Barcode/QR system = ticket verification layer (separate from event type)

**Sources**:
- [RA Pro - Sell Tickets on Resident Advisor](https://pro.ra.co/)
- [Database Modeling for an Event Ticketing Application | Ryan Boland](https://ryanboland.com/blog/database-modeling-for-an-event-ticketing-application/)

---

### 3. Eventbrite

**Platform Type**: General event ticketing and registration
**Scale**: Industry leader with extensive marketplace

#### Key Features
- Single event markup across multiple days (conferences)
- Individual event markup for recurring performances
- Structured data (Schema.org Event) for SEO
- Traffic grew 100% YoY after implementing event schema
- Star schemas for reporting (OBIEE integration)

#### Architecture Insights
- Uses **Schema.org Event** standard (single entity type)
- Conferences = single event with multi-day duration
- Recurring events = multiple individual event records (NOT subtypes)
- Proper indexing emphasized for relational database performance

**Database Pattern**:
```
Event (id, name, date, type, ...)
Ticket (id, event_id, type, price, availability, ...)
Attendee (id, ticket_id, name, email, ...)
```

**Relevance to Sonik**:
- Validates single events table approach
- Type field differentiates event categories
- Separate ticket entity (already in Sonik schema as ticket_tiers)

**Sources**:
- [Event - Schema.org Type](https://schema.org/Event)
- [The Benefits of Event Schema | Huckabuy](https://huckabuy.com/event-schema/)
- [How to use Event Schema for Multiple Dates with Examples](https://aubreyyung.com/event-schema-multiple-dates/)

---

### 4. Dice.fm

**Platform Type**: Mobile-first music ticketing with anti-scalping focus
**Scale**: Acquired by Fever (2025) to create largest independent live entertainment platform

#### Key Features
- Mobile-first with QR code tickets
- Tickets assigned to specific buyer's smartphone (anti-scalping)
- No PDF/email tickets (app-only activation)
- Time-limited QR code display before event
- Waiting list for sold-out shows
- Ticket transfers and resells via waiting list
- Dynamic pricing based on demand
- GraphQL API (Ticket Holders API)
- All tickets sourced directly from labels/promoters/venues

#### Architecture Insights
- **GraphQL API** with entities: events, ticket holders, sales
- Event genre segmentation suggests single events table with metadata
- Waiting list = state machine (on_sale → sold_out → resale)
- Dynamic pricing = flexible ticket tier pricing (not separate event types)

**API Structure** (inferred from GraphQL docs):
- Query by event with segmentation (genre, geography, spend)
- Ticket holder ownership tracking
- Event finance integration

**Relevance to Sonik**:
- Validates event state machine approach
- Anti-scalping = verification layer (not event type)
- Mobile-first ticket activation = separate concern from event schema

**Sources**:
- [Dice (ticketing company) - Wikipedia](https://en.wikipedia.org/wiki/Dice_(ticketing_company))
- [Ticket Holders API - DICE](https://partners-endpoint.dice.fm/graphql/docs/index.html)
- [How Does DICE Company Work? | CanvasBusinessModel](https://canvasbusinessmodel.com/blogs/how-it-works/dice-how-it-works)

---

## Database Pattern Analysis

### Single Table Inheritance (STI) vs Multi-Table Polymorphic

#### Single Table Inheritance (Recommended)
**Definition**: Multiple models share one database table, differentiated by a `type` column.

**When to use**:
- Models share most attributes
- Differ mainly in behavior (not structure)
- Need to query across all types efficiently

**Pros**:
- Simpler queries (no JOINs)
- Easy to add new types (no migrations)
- Supports type transitions (UPDATE type field)
- Better index performance (single B-tree)

**Cons**:
- Sparse columns (NULL values for type-specific fields)
- Schema changes affect all types

**Example**:
```sql
-- Single events table with type discriminator
CREATE TABLE events (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  event_type TEXT NOT NULL, -- 'ticketed_public', 'ticketed_private', 'non_ticketed_private', 'discovery'
  visibility TEXT, -- 'public', 'invite_only', 'hidden'
  is_ticketed BOOLEAN DEFAULT FALSE,
  requires_invite BOOLEAN DEFAULT FALSE,
  -- Common fields for all types
  description TEXT,
  event_date DATE,
  venue_name TEXT,
  -- Type-specific fields (nullable)
  guest_list JSONB, -- For private events
  scraped_source TEXT, -- For discovery events
  external_url TEXT, -- For discovery events
  status TEXT -- 'draft', 'published', 'on_sale', 'sold_out', 'completed', 'cancelled'
);
```

#### Multi-Table Polymorphic (Not Recommended)
**Definition**: Separate tables for each type, potentially with shared parent.

**When to use**:
- Models have completely different attributes
- Only share relationships to other entities

**Cons for Sonik**:
- Requires JOINs for cross-type queries
- Type migration = data migration between tables
- Complex event listing queries
- Harder to maintain consistency

**Sources**:
- [Rails STI: Single-Table Inheritance vs. Polymorphism | Netguru](https://www.netguru.com/blog/single-table-inheritance-rails)
- [The delegated type pattern and multi-table inheritance | Mateus Guimarães](https://mateusguimaraes.com/posts/the-delegated-type-pattern-and-multi-table-inheritance)

---

### MongoDB Polymorphic Pattern

**MongoDB Advantage**: Flexible schema naturally supports polymorphic data.

**Pattern**:
```javascript
// Ticketed Public Event
{
  _id: ObjectId("..."),
  event_type: "ticketed_public",
  name: "Sonar Festival 2025",
  visibility: "public",
  is_ticketed: true,
  requires_invite: false,
  event_date: ISODate("2025-06-15"),
  venue_name: "Parque Simón Bolívar",
  ticket_tiers: [...],
  status: "on_sale"
}

// Discovery Event
{
  _id: ObjectId("..."),
  event_type: "discovery",
  name: "Jazz Night at Café Berlin",
  visibility: "public",
  is_ticketed: false,
  requires_invite: false,
  scraped_source: "facebook_events",
  external_url: "https://facebook.com/events/...",
  status: "published"
}

// Non-Ticketed Private RSVP
{
  _id: ObjectId("..."),
  event_type: "non_ticketed_private",
  name: "Daniel's Birthday Party",
  visibility: "invite_only",
  is_ticketed: false,
  requires_invite: true,
  guest_list: ["user_id_1", "user_id_2"],
  rsvp_count: 24,
  rsvp_limit: 50,
  status: "published"
}
```

**Mongoose Discriminators**:
```javascript
const eventSchema = new Schema({
  name: String,
  event_type: { type: String, required: true },
  visibility: String,
  is_ticketed: Boolean,
  // ... common fields
}, { discriminatorKey: 'event_type' });

const Event = mongoose.model('Event', eventSchema);

// Type-specific models with shared collection
const TicketedPublicEvent = Event.discriminator('ticketed_public', new Schema({
  ticket_tiers: [ticketTierSchema]
}));

const DiscoveryEvent = Event.discriminator('discovery', new Schema({
  scraped_source: String,
  external_url: String
}));
```

**Sources**:
- [Store Polymorphic Data - MongoDB Docs](https://www.mongodb.com/docs/manual/data-modeling/design-patterns/polymorphic-data/polymorphic-schema-pattern/)
- [Building with Patterns: The Polymorphic Pattern | MongoDB](https://www.mongodb.com/developer/products/mongodb/polymorphic-pattern/)
- [Mongoose Discriminators](https://mongoosejs.com/docs/discriminators.html)

---

## Organizer/Promoter/Venue Modeling

### Industry Distinction

**Event Organizer**:
- Plans and coordinates all event aspects
- Sets date, location, entertainment
- Manages budget and vendors
- May be organization OR individual

**Event Promoter**:
- Responsible for marketing and publicity
- Drives ticket sales
- Coordinates sponsorships
- Often shares revenue with organizer

**Venue**:
- Physical location hosting the event
- Can be organizer, promoter, or just space provider

**Reality**: Roles often overlap, especially in smaller events. Larger events have separate entities.

### Sonik Decisions

1. **Organizer = market.organizations (Primary)**
   - All ticketed events MUST have organization_id
   - Organizations can be: promoter, venue, festival, agency, brand
   - `organization_type` field differentiates roles

2. **Individuals for RSVP Events**
   - Non-ticketed private events can have `user_id` instead of `organization_id`
   - No ticket sales = no organization requirement

3. **Venue as Separate Entity**
   - Venue stored as string fields in event: `venue_name`, `venue_address`, `city`
   - Future: Link to `market.entities` where `entity_type = 'venue'`
   - Allows venue to be promoter/organizer OR just location

4. **Performers/Artists via market.entities**
   - `market.entity_relationships` table links entities to events
   - `relationship_type`: performer, headliner, supporting, promoter, sponsor, venue_owner

**Sources**:
- [Event Organizer vs Event Promoter: What's the Difference? | Event Vesta](https://info.eventvesta.com/organizer/event-organizer-vs-event-promoter-whats-the-difference/)
- [Venue Promoter Agreements: Key Provisions and Considerations | Territory Law](https://www.tenforjustice.com/venue-promoter-agreements-key-provisions-and-considerations/)

---

## Recommended Schema Design

### Option 1: Extend Existing Supabase Schema (Recommended)

**Rationale**: Sonik already has `finance.events` in Supabase. Add discriminator fields for event types.

#### Schema Changes

```sql
-- Add to finance.events table
ALTER TABLE finance.events
  ADD COLUMN event_category TEXT DEFAULT 'ticketed_public'
    CHECK (event_category IN ('ticketed_public', 'ticketed_private', 'non_ticketed_private', 'discovery')),
  ADD COLUMN visibility TEXT DEFAULT 'public'
    CHECK (visibility IN ('public', 'invite_only', 'hidden')),
  ADD COLUMN is_ticketed BOOLEAN GENERATED ALWAYS AS
    (event_category LIKE 'ticketed%') STORED,
  ADD COLUMN requires_invite BOOLEAN GENERATED ALWAYS AS
    (event_category LIKE '%private') STORED,
  ADD COLUMN creator_user_id UUID REFERENCES shared.users(id), -- For individual-created RSVP events
  ADD COLUMN guest_list_ids UUID[], -- For private events
  ADD COLUMN rsvp_count INTEGER DEFAULT 0, -- For non-ticketed events
  ADD COLUMN rsvp_limit INTEGER, -- Max RSVPs
  ADD COLUMN scraped_source TEXT, -- For discovery events: 'facebook', 'instagram', 'bandsintown', etc.
  ADD COLUMN external_url TEXT, -- For discovery events
  ADD COLUMN external_event_id TEXT, -- Source platform's event ID
  ADD COLUMN can_transition_to_ticketed BOOLEAN DEFAULT FALSE; -- Discovery → Ticketed flag

-- Make organization_id nullable for individual RSVP events
ALTER TABLE finance.events
  ALTER COLUMN organization_id DROP NOT NULL;

-- Add constraint: ticketed events MUST have organization
ALTER TABLE finance.events
  ADD CONSTRAINT ticketed_events_require_org
    CHECK (
      (is_ticketed = TRUE AND organization_id IS NOT NULL) OR
      (is_ticketed = FALSE)
    );

-- Add constraint: either organization OR creator (not both)
ALTER TABLE finance.events
  ADD CONSTRAINT event_has_owner
    CHECK (
      (organization_id IS NOT NULL AND creator_user_id IS NULL) OR
      (organization_id IS NULL AND creator_user_id IS NOT NULL)
    );

-- Indexes
CREATE INDEX idx_events_category ON finance.events(event_category);
CREATE INDEX idx_events_visibility ON finance.events(visibility);
CREATE INDEX idx_events_creator ON finance.events(creator_user_id);
CREATE INDEX idx_events_scraped_source ON finance.events(scraped_source) WHERE scraped_source IS NOT NULL;
CREATE UNIQUE INDEX idx_events_external_unique ON finance.events(scraped_source, external_event_id)
  WHERE scraped_source IS NOT NULL AND external_event_id IS NOT NULL;
```

#### Event Type Rules

| Event Category | organization_id | creator_user_id | is_ticketed | visibility | ticket_tiers |
|----------------|-----------------|-----------------|-------------|------------|--------------|
| ticketed_public | Required | NULL | TRUE | public | Required |
| ticketed_private | Required | NULL | TRUE | invite_only | Required |
| non_ticketed_private | Optional | Required if no org | FALSE | invite_only | Empty |
| discovery | NULL | NULL | FALSE | public | Empty |

---

### Option 2: MongoDB Parallel Collection (Operational Data)

**Use Case**: Fast reads/writes for operational data, sync to Supabase for analytics.

#### MongoDB Schema

```javascript
// events collection
{
  _id: ObjectId("..."),
  supabase_event_id: "uuid-...", // Foreign key to Supabase
  event_category: "ticketed_public", // or ticketed_private, non_ticketed_private, discovery
  visibility: "public", // or invite_only, hidden
  is_ticketed: true,
  requires_invite: false,

  // Ownership (one of these must be set)
  organization_id: "uuid-...", // References market.organizations
  creator_user_id: "uuid-...", // References shared.users (for RSVP events)

  // Common fields
  name: "Event Name",
  slug: "event-name-2025",
  description: "...",
  event_date: ISODate("2025-06-15T20:00:00Z"),
  event_time: "20:00",
  timezone: "America/Bogota",
  venue_name: "Venue Name",
  venue_address: "...",
  city: "Bogotá",
  country_code: "CO",

  // Status lifecycle
  status: "on_sale", // draft, published, on_sale, sold_out, completed, cancelled, postponed
  published_at: ISODate("..."),
  on_sale_at: ISODate("..."),
  off_sale_at: ISODate("..."),

  // Type-specific fields
  guest_list_ids: ["user_id_1", "user_id_2"], // For private events
  rsvp_count: 24, // For non-ticketed events
  rsvp_limit: 50,

  scraped_source: "facebook_events", // For discovery events
  external_url: "https://...",
  external_event_id: "fb_event_123",
  can_transition_to_ticketed: false, // Discovery → Ticketed flag

  // Metadata
  capacity: 500,
  tickets_sold: 234,
  poster_url: "...",
  cover_image_url: "...",

  created_at: ISODate("..."),
  updated_at: ISODate("...")
}
```

**Sync Strategy**:
- MongoDB = source of truth for operational data (fast reads/writes)
- Supabase = analytics, reporting, long-term storage
- Sync via Change Streams or periodic ETL (metadata.job_runs)

---

## Event Lifecycle State Machine

### State Transitions

```
Discovery Event Lifecycle:
  discovered → published → archived
                    ↓
            (claim & convert)
                    ↓
            ticketed_public (draft)

Individual RSVP Event:
  draft → published → completed → archived

Ticketed Event:
  draft → published → on_sale → sold_out → completed → archived
                          ↓          ↓
                     cancelled  postponed → rescheduled (new event)
```

### Status Field Values

| Status | Description | Allowed Event Types |
|--------|-------------|---------------------|
| draft | Being created, not visible | All except discovery |
| discovered | Scraped, not claimed | discovery only |
| published | Visible, not on sale yet | All |
| on_sale | Tickets available | ticketed_public, ticketed_private |
| sold_out | No tickets left | ticketed_public, ticketed_private |
| completed | Event finished | All |
| cancelled | Event won't happen | All |
| postponed | Delayed, new date TBD | All |
| archived | Historical record | All |

### Type Transition Logic

**Discovery → Ticketed Public**:
```sql
-- Claim discovery event and convert to ticketed
UPDATE finance.events
SET
  event_category = 'ticketed_public',
  organization_id = 'claiming_org_uuid',
  status = 'draft',
  can_transition_to_ticketed = FALSE,
  scraped_source = NULL, -- Clear discovery metadata
  external_url = NULL
WHERE
  id = 'event_id'
  AND event_category = 'discovery'
  AND can_transition_to_ticketed = TRUE;
```

**Non-Ticketed Private → Ticketed Private**:
```sql
-- Individual converts RSVP event to ticketed (must have organization)
UPDATE finance.events
SET
  event_category = 'ticketed_private',
  organization_id = 'new_org_uuid',
  creator_user_id = NULL, -- Transfer ownership to org
  is_ticketed = TRUE
WHERE
  id = 'event_id'
  AND event_category = 'non_ticketed_private'
  AND creator_user_id IS NOT NULL;
```

**Sources**:
- [Richard Clayton - Use State Machines!](https://rclayton.silvrback.com/use-state-machines)
- [State Machines for Event-Driven Systems | Barr Group](https://barrgroup.com/embedded-systems/how-to/state-machines-event-driven-systems)

---

## Edge Cases to Consider

### 1. Hybrid Events (Online + In-Person)
**Challenge**: Same event, multiple ticket types (in-person vs virtual).
**Solution**: Use `ticket_tiers` with `tier_type` field:
- `tier_type = 'in_person'`
- `tier_type = 'virtual_streaming'`
- `tier_type = 'hybrid_access'`

### 2. Multi-Day Festivals
**Challenge**: Single festival with multiple days/stages.
**Solution Option A**: Single event with `event_date` = start date, add `end_date` field.
**Solution Option B**: Parent-child events (festival → daily lineups).
```sql
ALTER TABLE finance.events
  ADD COLUMN parent_event_id UUID REFERENCES finance.events(id),
  ADD COLUMN is_multi_day BOOLEAN DEFAULT FALSE,
  ADD COLUMN end_date DATE;
```

### 3. Recurring Events (Weekly Shows)
**Challenge**: Same event repeats multiple times.
**Solution**: Create separate event records, link via `series_id`:
```sql
ALTER TABLE finance.events
  ADD COLUMN series_id UUID, -- Groups recurring events
  ADD COLUMN recurrence_pattern JSONB; -- { frequency: 'weekly', day: 'friday' }

CREATE INDEX idx_events_series ON finance.events(series_id) WHERE series_id IS NOT NULL;
```

### 4. Discovery Event Deduplication
**Challenge**: Same event scraped from multiple sources.
**Solution**:
- Fuzzy matching on `(name, event_date, venue_name, city)`
- Store all sources in `scraped_sources` JSONB array:
```sql
ALTER TABLE finance.events
  ADD COLUMN scraped_sources JSONB DEFAULT '[]'::jsonb;
  -- [{ source: 'facebook', external_id: '...', url: '...' }, ...]
```

### 5. Private Event Invite Lists
**Challenge**: Managing guest lists for invite-only events.
**Solution**: `guest_list_ids UUID[]` array + separate `event_invites` table:
```sql
CREATE TABLE finance.event_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES finance.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES shared.users(id),
  invitee_email TEXT, -- For users not yet registered
  invitee_phone TEXT,
  invited_by UUID REFERENCES shared.users(id),
  invite_code TEXT UNIQUE, -- Share link code
  status TEXT DEFAULT 'pending', -- pending, accepted, declined, expired
  rsvp_response TEXT, -- going, maybe, not_going
  guests_count INTEGER DEFAULT 1, -- +1, +2, etc.
  created_at TIMESTAMPTZ DEFAULT NOW(),
  responded_at TIMESTAMPTZ,
  UNIQUE(event_id, user_id)
);

CREATE INDEX idx_event_invites_event ON finance.event_invites(event_id);
CREATE INDEX idx_event_invites_user ON finance.event_invites(user_id);
CREATE INDEX idx_event_invites_code ON finance.event_invites(invite_code);
```

### 6. Organizer Verification
**Challenge**: Prevent unauthorized claiming of discovery events.
**Solution**: Require proof of ownership before allowing transition:
- `verified_at TIMESTAMPTZ` in market.organizations
- `can_transition_to_ticketed` flag requires admin approval
- Verification workflow via support tickets

### 7. Free Ticketed Events (Public RSVP with Capacity Limits)
**Challenge**: Public event, free tickets, but need capacity tracking.
**Approach**: Use `ticketed_public` with `price_cents = 0` ticket tier:
```sql
-- Free public event with capacity
INSERT INTO finance.events (...) VALUES (
  event_category = 'ticketed_public',
  visibility = 'public',
  capacity = 200
);

INSERT INTO finance.ticket_tiers (...) VALUES (
  event_id = 'event_uuid',
  name = 'Free RSVP',
  tier_type = 'general_admission',
  price_cents = 0,
  quantity = 200
);
```

### 8. Event Ownership Transfer
**Challenge**: Individual creates RSVP event, later wants to sell tickets.
**Solution**: User creates organization, transfer ownership:
```sql
-- Step 1: User creates organization
INSERT INTO market.organizations (...) VALUES (...);

-- Step 2: Transfer event ownership
UPDATE finance.events
SET
  event_category = 'ticketed_private', -- Or ticketed_public
  organization_id = 'new_org_uuid',
  creator_user_id = NULL,
  status = 'draft' -- Reset to draft for configuration
WHERE
  id = 'event_uuid'
  AND creator_user_id = 'user_uuid'
  AND event_category = 'non_ticketed_private';
```

---

## Recommendations

### 1. Use Single Table Polymorphic Pattern
- Extend `finance.events` in Supabase with discriminator fields
- Avoid multi-table inheritance complexity
- Supports mid-lifecycle type transitions
- Simpler queries and better index performance

### 2. MongoDB for Operations, Supabase for Analytics
- MongoDB: Fast reads/writes for event discovery, RSVP tracking
- Supabase: Source of truth for ticketed events, financial transactions
- Sync via Change Streams or periodic ETL

### 3. Organizer = First-Class Entity
- Use `market.organizations` for all ticketed events
- Allow `creator_user_id` for individual RSVP events
- Separate venue from organizer (string fields + future entity link)

### 4. Event State Machine
- Implement status-based lifecycle management
- Support Discovery → Ticketed transitions with verification
- Use triggers to enforce state transition rules

### 5. JSONB for Flexibility
- Store type-specific data in JSONB where appropriate
- Use typed columns for query-critical fields
- Balance between structure and flexibility

---

## Implementation Priority

**Phase 1**: Extend Supabase Schema
1. Add discriminator fields to `finance.events`
2. Create constraints for event type rules
3. Add indexes for new query patterns
4. Migrate existing events to `ticketed_public` category

**Phase 2**: MongoDB Operational Layer
1. Create events collection with polymorphic schema
2. Implement Mongoose discriminators
3. Set up Change Streams sync to Supabase
4. Build event discovery scraper ingestion

**Phase 3**: State Machine & Transitions
1. Implement status transition validators
2. Build Discovery → Ticketed claim workflow
3. Add event ownership transfer logic
4. Create event series/recurring support

**Phase 4**: Advanced Features
1. Event invites table for guest list management
2. Multi-day festival parent-child relationships
3. Deduplication for discovery events
4. Hybrid event support (virtual + in-person)

---

## Conclusion

The single polymorphic events table pattern is **validated by industry leaders** (Posh, RA, Eventbrite, Dice) and **best suited for Sonik's requirements**. It provides:

- Flexibility for 4 event types with shared attributes
- Mid-lifecycle type transitions without data migration
- Simpler queries and better performance
- Natural fit for both MongoDB and PostgreSQL/Supabase
- Clear organizer/promoter/venue separation

**Next Steps**:
1. Review with stakeholders
2. Create migration scripts for Phase 1
3. Update API contracts to support event categories
4. Implement event type validation in application layer

---

## Sources

### Platform Research
- [Event platform POSH wants to democratize event planning | TechCrunch](https://techcrunch.com/2023/04/27/event-management-ticketing-platform-posh-raises-5-million-seed-round/)
- [POSH Reviews 2025 | G2](https://www.g2.com/products/posh-posh/reviews)
- [How Does POSH Company Work? | CanvasBusinessModel](https://canvasbusinessmodel.com/blogs/how-it-works/posh-how-it-works)
- [Explore your Event Analytics | Posh Knowledge Base](https://support.posh.vip/en/articles/10723755-explore-your-event-analytics)
- [RA Tickets | Resident Advisor](https://ra.co/tickets)
- [RA Pro - Sell Tickets on Resident Advisor](https://pro.ra.co/)
- [Database Modeling for an Event Ticketing Application | Ryan Boland](https://ryanboland.com/blog/database-modeling-for-an-event-ticketing-application/)
- [A Data Model for Online Concert Ticket Sales | Vertabelo Database Modeler](https://vertabelo.com/blog/a-data-model-for-online-concert-ticket-sales/)
- [Event - Schema.org Type](https://schema.org/Event)
- [The Benefits of Event Schema | Huckabuy](https://huckabuy.com/event-schema/)
- [How to use Event Schema for Multiple Dates with Examples](https://aubreyyung.com/event-schema-multiple-dates/)
- [Dice (ticketing company) - Wikipedia](https://en.wikipedia.org/wiki/Dice_(ticketing_company))
- [Ticket Holders API - DICE](https://partners-endpoint.dice.fm/graphql/docs/index.html)
- [How Does DICE Company Work? | CanvasBusinessModel](https://canvasbusinessmodel.com/blogs/how-it-works/dice-how-it-works)

### Database Patterns
- [Rails STI: Single-Table Inheritance vs. Polymorphism | Netguru](https://www.netguru.com/blog/single-table-inheritance-rails)
- [Designing Events and Event Streams - Single vs. Multiple Event Streams | Confluent](https://developer.confluent.io/courses/event-design/single-vs-multiple-event-streams/)
- [Design a Ticket Booking Site Like Ticketmaster | Hello Interview](https://www.hellointerview.com/learn/system-design/problem-breakdowns/ticketmaster)
- [The delegated type pattern and multi-table inheritance | Mateus Guimarães](https://mateusguimaraes.com/posts/the-delegated-type-pattern-and-multi-table-inheritance)
- [Store Polymorphic Data - MongoDB Docs](https://www.mongodb.com/docs/manual/data-modeling/design-patterns/polymorphic-data/polymorphic-schema-pattern/)
- [Building with Patterns: The Polymorphic Pattern | MongoDB](https://www.mongodb.com/developer/products/mongodb/polymorphic-pattern/)
- [Mongoose Discriminators](https://mongoosejs.com/docs/discriminators.html)
- [Using Polymorphism with MongoDB | GeeksforGeeks](https://www.geeksforgeeks.org/mongodb/using-polymorphism-with-mongodb/)

### Organizer/Promoter Modeling
- [Event Organizer vs Event Promoter: What's the Difference? | Event Vesta](https://info.eventvesta.com/organizer/event-organizer-vs-event-promoter-whats-the-difference/)
- [Venue Promoter Agreements: Key Provisions and Considerations | Territory Law](https://www.tenforjustice.com/venue-promoter-agreements-key-provisions-and-considerations/)
- [Tickets for Live Entertainment Events | EveryCRSReport](https://www.everycrsreport.com/reports/R48179.html)
- [Why no one has solved event discovery | Hugh Malkin](http://www.hughmalkin.com/blogwriter/2015/9/23/why-no-one-has-solved-event-discovery)
- [Launch Feature Rich Event Discovery and Marketing Platform | FatBit](https://www.fatbit.com/fab/feature-analysis-for-building-event-discovery-marketplace/)

### Event Lifecycle & State Machines
- [Richard Clayton - Use State Machines!](https://rclayton.silvrback.com/use-state-machines)
- [Transitions and events - python-statemachine](https://python-statemachine.readthedocs.io/en/latest/transitions.html)
- [Event-driven finite-state machine - Wikipedia](https://en.wikipedia.org/wiki/Event-driven_finite-state_machine)
- [State Machines for Event-Driven Systems | Barr Group](https://barrgroup.com/embedded-systems/how-to/state-machines-event-driven-systems)
- [What's the difference between an RSVP and a ticketed event? | Splash Help Center](https://support.splashthat.com/hc/en-us/articles/201649869-What-s-the-difference-between-an-RSVP-and-a-ticketed-event)

### Schema Versioning
- [Simple patterns for events schema versioning - Event-Driven.io](https://event-driven.io/en/simple_events_versioning_patterns/)
- [Events Versioning | Marten](https://martendb.io/events/versioning.html)
- [Zero-Downtime Database Migration: The Complete Engineering Guide | DEV Community](https://dev.to/ari-ghosh/zero-downtime-database-migration-the-definitive-guide-5672)
