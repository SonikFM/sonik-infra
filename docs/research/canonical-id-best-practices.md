# Canonical ID Best Practices for Entity Verification in Music/Events Industry

**Date:** 2025-12-10
**Purpose:** Research canonical ID strategies for ownership verification of venues, artists, and organizations in Sonik's event aggregation platform

## Executive Summary

This research examines how major platforms identify and verify ownership of entities in the music and events industry. The goal is to establish a canonical ID hierarchy for Sonik that prioritizes **ownership verification** over deduplication, ensuring that only entities with verifiable ownership can claim attribution data.

**Key Findings:**
- No single identifier is universal across all platforms
- Verification methods differ significantly between entity types
- Google Place IDs are NOT permanent (can expire after 12 months)
- ISNI is emerging as the music industry standard for artists (adopted by UMG, YouTube)
- Social media verification (Instagram, Facebook) requires existing notability
- Domain ownership via DNS TXT records is the most reliable organization identifier

## Entity Type Analysis

### 1. Venues

#### Platform Approaches

**Google Business Profile (formerly Google My Business)**
- **Identifier:** Place ID (textual, variable length)
- **Permanence:** NOT permanent - can expire after 12+ months, should be refreshed regularly
- **Alternative:** CID (Customer ID) - 64-bit permanent identifier, but not officially part of Google Maps Platform APIs
- **Verification Methods:**
  - Video verification (most common in 2025) - 360° interior/exterior recording
  - Phone verification - automated call with code
  - Email verification - code sent to business email
  - Postcard verification (being phased out)
  - Instant verification (for businesses verified in Google Search Console)
- **Ownership Proof Required:**
  - Utility bills (water, electricity, gas)
  - Business licenses
  - Lease agreements
  - Fire inspection reports
  - Signage photos
  - Domain ownership proof
- **Timeline:** Most verifications complete within hours; some require 2-3 business days
- **Cost:** 100% free

**Yelp**
- **Identifier:** Yelp business page URL
- **Verification Method:**
  - Automated phone call to business number (instant)
  - Manual review by support team (2-3 business days)
- **Ownership Transfer:** If unclaimed for 90+ days, new user can claim
- **Ownership Disputes:** Support team mediates if already claimed by someone else

**Instagram Business Verification**
- **Identifier:** Instagram handle/URL
- **Two Verification Types:**
  1. **Free verification** - Based on notability and activity
  2. **Meta Verified** - Paid subscription ($14.99-$349.99/month)
- **Requirements:**
  - Authentic (real business)
  - Unique (only presence for that business)
  - Complete (public, bio, photo, 1+ post)
  - Notable (well-known, highly searched)
- **Ownership Proof:**
  - Government-issued photo ID
  - Utility bill with company name
  - Articles of incorporation
  - Tax return
- **Timeline:** Up to 30 days review
- **Challenge:** Must have "high likelihood of being impersonated" - limits smaller venues

#### Recommended Canonical ID Hierarchy for Venues

1. **Primary:** Google Place ID + last refresh date (refresh if >12 months old)
2. **Secondary:** Instagram URL (for venues with verified accounts)
3. **Tertiary:** Yelp business URL
4. **Fallback Strategy:**
   - If no Google Place ID exists, use Instagram URL
   - If neither exists, flag entity as "unverifiable" - do NOT scrape
   - Allow manual verification via documentation upload (utility bill, business license)

**Verification Flow:**
```
1. User claims venue via Sonik platform
2. System requires either:
   a) Google Place ID → User must verify via Google Business Profile → Link GBP to Sonik
   b) Instagram URL → User must verify Instagram ownership → OAuth connection or screenshot proof
3. If verified, transfer all historical attribution data to verified owner
4. Set reminder to refresh Google Place ID annually
```

### 2. Artists/Performers

#### Platform Approaches

**Spotify for Artists**
- **Identifier:** Spotify Artist URI (spotify:artist:XXXXX)
- **Verification Method:**
  - Create/claim artist profile at artists.spotify.com
  - Connect social media (Instagram/Twitter) OR official website
  - Verify via music distributor (DistroKid, CD Baby, TuneCore, etc.)
- **Requirements:**
  - At least 1 song released on Spotify
  - Artist profile created automatically when music published
  - No minimum follower count (changed from 250 followers)
- **Timeline:** Few days for approval
- **Benefits:** Blue checkmark next to artist name
- **Distributor Shortcuts:** Instant verification via DistroKid, CD Baby

**MusicBrainz (Open Database)**
- **Identifier:** MBID (MusicBrainz Identifier) - 36-character UUID
- **Permanence:** Permanent, stable identifier
- **Example:** Queen = `0383dadf-2a4e-4d10-a46a-e9e041da8eb3`
- **Key Features:**
  - Assigned to artists, recordings, works, labels, areas, places, URLs
  - Disambiguates entities with same name
  - Can have multiple MBIDs (when merged, old IDs redirect)
  - Open-source, community-maintained
- **Weakness:** Not ownership-based - anyone can edit (like Wikipedia)
- **Use Case:** Better for deduplication than verification

**ISNI (International Standard Name Identifier)**
- **Identifier:** 16-digit unique code
- **Industry Status:** **Emerging as the music industry standard in 2025**
- **Major Adoptions:**
  - Universal Music Group (first major label to adopt universally)
  - YouTube (requires ISNI for all creators using music)
  - Being integrated across streaming platforms
- **Key Features:**
  - "Digital passport" for artists, songwriters, producers
  - Links to collection society identifiers (IPI, IPN)
  - Enables accurate attribution and royalty tracking
  - Free automated ISNI via Sound Credit during account creation
- **Example Use:** Links artist's performer records to songwriter records to revenue streams
- **2025 Trend:** Industry groups estimate hundreds of millions lost annually to metadata errors; ISNI adoption accelerating

**Bandsintown**
- **Identifier:** Bandsintown Artist ID (numeric, in URL)
- **Example:** Taylor Swift = 217815
- **Verification:**
  - Automatic verified badge at 100+ followers
  - Manual verification via Facebook page (admin access required)
  - Manual verification via Twitter account access
  - Manual support request (2-3 business days)
- **Requirements:** Explain relationship with artist
- **Limitation:** Popularity threshold may exclude emerging artists

**Songkick**
- **Identifier:** Songkick Artist ID (numeric, in URL)
- **Verification:** Gradually rolling out for most popular artists only
- **Management:** Requires personal Songkick account (like Facebook page admin)
- **API Integration:** Accepts both Songkick IDs and MusicBrainz IDs
- **Limitation:** Not widely available for smaller artists

**Instagram Artist Verification**
- Same process as venues (see above)
- More accessible for artists with existing fanbase
- Meta Verified offers dedicated artist support

#### Related Music Industry Identifiers (Not for Ownership, but Important Context)

- **ISRC (International Standard Recording Code):** Identifies specific recordings (songs)
- **ISWC (International Standard Musical Work Code):** Identifies musical works (compositions)
- **IPI (Interested Party Information):** Identifies songwriters, composers, publishers
- **IPN (International Performer Number):** Identifies performers on recordings
- **AcoustID:** Open-source acoustic fingerprint system

#### Recommended Canonical ID Hierarchy for Artists

1. **Primary:** ISNI (International Standard Name Identifier)
   - Most future-proof
   - Industry-wide adoption accelerating
   - Links to royalty/revenue systems
   - Free via Sound Credit
2. **Secondary:** Spotify Artist URI
   - Widely adopted
   - Easy verification via distributors
   - Good indicator of professional artist
3. **Tertiary:** Instagram URL (verified accounts)
   - Social proof of notability
   - OAuth verification possible
4. **Quaternary:** MusicBrainz MBID
   - Stable, permanent identifier
   - Good for deduplication
   - NOT ownership-based (community edits)
5. **Fallback Strategy:**
   - If none available, allow manual verification via:
     - Music distributor dashboard screenshot showing artist ownership
     - Social media account verification (Instagram/Facebook/Twitter OAuth)
     - Official website with contact info matching Sonik account email
   - Require at least 1 publicly verifiable presence

**Verification Flow:**
```
1. User claims artist profile via Sonik platform
2. System checks for canonical IDs in priority order:
   a) ISNI → Verify via Sound Credit or official ISNI registry
   b) Spotify URI → Verify via Spotify for Artists OAuth or API
   c) Instagram → Verify via Meta OAuth or manual screenshot
3. Cross-reference social media handles to ensure consistency
4. If verified, transfer all historical attribution data
5. Store MusicBrainz MBID for deduplication (separate from verification)
```

### 3. Organizations (Promoters, Labels, Venues Networks)

#### Platform Approaches

**Domain Ownership (DNS TXT Records)**
- **Identifier:** Domain name (e.g., livenation.com, aeg.com)
- **Verification Method:** DNS TXT record added to domain's zone file
- **Process:**
  1. Platform provides unique TXT record (random string)
  2. Organization adds record to DNS settings
  3. Platform checks DNS to verify ownership
- **Example:** `apple-domain-verification=0RaNdOm1LeTtErS2aNd3NuMbErS4`
- **Timeline:** 1-72 hours for DNS propagation (typically <1 hour)
- **Permanence:** Highly reliable - only domain owner can modify DNS
- **Used By:** Google Workspace, Apple Business Manager, SSL certificate authorities
- **Advantages:**
  - Proves control over internet presence
  - Free verification method
  - Industry-standard approach
  - No manual review required

**LinkedIn Company Page**
- **Identifier:** LinkedIn company page URL
- **Claiming Requirements:**
  - Current employee with position listed in profile
  - Company email address confirmed (e.g., name@companyname.com)
  - Profile >50% complete
  - Minimum 10 connections
- **Verification for Badge:**
  - Accurate data (location, website URL)
  - Active page admin
  - Page ownership confirmed
  - Compliance with LinkedIn policies
- **Ownership Proof:**
  - Business license
  - Articles of incorporation
  - Utility bills in company name
- **Transfer Process:** Request admin access via LinkedIn support with documentation

**Google Business Profile (Multi-Location)**
- Same verification as single venues (see above)
- **Bulk Verification:** Available for organizations with multiple locations
- **Chain Management:** Special features for business chains

**Instagram Business**
- Same process as venues/artists
- **Meta Verified for Businesses:** $14.99-$349.99/month (varies by plan)
- Multi-platform support: Facebook + Instagram + WhatsApp

#### Recommended Canonical ID Hierarchy for Organizations

1. **Primary:** Domain name (verified via DNS TXT record)
   - Most reliable proof of organization identity
   - Industry-standard verification
   - Free and fast
2. **Secondary:** LinkedIn Company Page URL
   - Business-focused social proof
   - Requires company email verification
   - Shows organizational legitimacy
3. **Tertiary:** Instagram Business URL (verified accounts)
   - Consumer-facing brand presence
   - Meta Verified option for enhanced trust
4. **Fallback Strategy:**
   - If no domain (rare for legitimate organizations), require:
     - Business registration documents
     - Articles of incorporation
     - Tax ID/EIN verification
     - Utility bill or lease agreement
   - Flag organizations without domain as "verification required"

**Verification Flow:**
```
1. User claims organization via Sonik platform
2. Primary verification: DNS TXT record
   a) System generates unique verification string
   b) User adds TXT record to domain DNS
   c) System polls DNS for verification (1-72 hour window)
   d) Auto-verify once detected
3. Secondary verification: LinkedIn Company Page
   a) User provides LinkedIn page URL
   b) System checks if LinkedIn page domain matches claimed domain
   c) User proves admin access via screenshot or LinkedIn OAuth
4. If verified, transfer all historical attribution data
5. Store all verified properties (domain, LinkedIn, Instagram) for future verification
```

## Cross-Platform Verification Best Practices

### 1. Multi-Factor Verification Approach

**Recommended Strategy:**
- Require at least ONE canonical ID from primary/secondary tier
- Award "trust score" based on number of verified identifiers
- Higher trust = more platform features (e.g., edit scraped data, priority support)

**Trust Tiers:**
```
TIER 1 (Basic Access):
- 1 canonical ID verified
- Can claim attribution data
- Read-only view of scraped data

TIER 2 (Enhanced Access):
- 2+ canonical IDs verified OR 1 primary + social verification
- Can suggest edits to scraped data (subject to review)
- Can link multiple entities (e.g., artist + label)

TIER 3 (Full Access):
- 3+ canonical IDs verified, including domain (for orgs) or ISNI (for artists)
- Can directly edit scraped data
- API access for data export
- Priority customer support
```

### 2. Handling Edge Cases

**Scenario: Entity has no canonical IDs**
- **Decision:** Do NOT scrape or include in database
- **Rationale:** Without verifiable ownership, cannot safely transfer attribution data
- **Exception:** Manual review for high-value entities (major festivals, iconic venues)

**Scenario: Multiple users claim same entity**
- **Resolution Process:**
  1. First verified user gets initial access
  2. Second claimant triggers dispute process
  3. Platform requests additional verification from both parties
  4. Manual review of documentation
  5. May result in shared ownership (e.g., venue management company + venue owner)

**Scenario: Canonical ID changes (business moves, artist name change)**
- **Solution:** Allow users to update canonical IDs with verification
- **Process:**
  1. User submits new canonical ID
  2. Re-verification required for new ID
  3. System maintains link between old and new IDs
  4. Attribution data follows the entity

**Scenario: Google Place ID expires (>12 months old)**
- **Automated System:**
  1. Quarterly job checks all Place IDs for age
  2. If >10 months old, email venue owner to refresh
  3. Provide refresh button in dashboard (triggers Places API call)
  4. If >18 months old and not refreshed, mark as "verification expired"
  5. Require re-verification to maintain access

### 3. Verification Flow Architecture

**Initial Claim:**
```
User → Sonik Platform → "Claim Entity" → Select Entity Type →
  → System presents canonical ID options (ordered by priority) →
  → User selects ID type and provides value →
  → System initiates verification flow (platform-specific) →
  → User completes verification on external platform →
  → User returns to Sonik with proof →
  → System validates proof →
  → Access granted + attribution data transferred
```

**Ongoing Verification:**
- Annual reminder to refresh Google Place IDs
- Email alerts if canonical ID becomes invalid (e.g., Instagram account deleted)
- Option to add additional canonical IDs to strengthen trust score

### 4. Privacy and Data Handling

**Best Practices:**
- Store only public identifiers (IDs, URLs)
- Do NOT store verification tokens/passwords
- Use OAuth where possible (Spotify, Instagram, LinkedIn)
- For DNS verification, delete TXT record requirement after verification complete
- Allow users to disconnect canonical IDs (triggers re-verification)

## Platform-Specific Implementation Recommendations

### For Venues

**Phase 1 (MVP):**
- Google Place ID as primary (with refresh system)
- Instagram URL as fallback
- Manual verification upload for edge cases

**Phase 2 (Enhanced):**
- Yelp integration
- Facebook Places integration
- Multi-venue chain management (for organizations)

### For Artists

**Phase 1 (MVP):**
- Spotify Artist URI as primary (easiest verification via OAuth)
- Instagram URL as fallback
- Manual verification via distributor screenshot

**Phase 2 (Enhanced):**
- ISNI integration (as industry adoption grows)
- MusicBrainz for deduplication (separate from verification)
- Bandsintown/Songkick for event cross-referencing

### For Organizations

**Phase 1 (MVP):**
- Domain verification via DNS TXT record
- LinkedIn Company Page as fallback
- Manual verification via business documents

**Phase 2 (Enhanced):**
- Integration with business registries (varies by country)
- D&B (Dun & Bradstreet) number for established companies
- Multi-brand management features

## Recommended Final Hierarchy

### Venues
1. Google Place ID (primary, with refresh <12 months)
2. Instagram Business URL (verified accounts)
3. Yelp Business URL
4. Manual verification (utility bill, business license)

### Artists
1. ISNI (future-proof, industry standard)
2. Spotify Artist URI (easy OAuth, widely adopted)
3. Instagram URL (verified accounts)
4. MusicBrainz MBID (deduplication, not verification)
5. Manual verification (distributor proof, social media)

### Organizations
1. Domain name (DNS TXT verification)
2. LinkedIn Company Page URL (company email required)
3. Instagram Business URL (verified accounts)
4. Manual verification (articles of incorporation, tax ID)

## Cost and Timeline Estimates

### Free Verification Methods
- Google Business Profile: Free (time: minutes to days)
- Yelp: Free (time: instant to 3 days)
- Spotify for Artists: Free (time: 2-5 days)
- ISNI (via Sound Credit): Free (time: instant to 1 day)
- MusicBrainz: Free (time: instant, community-edited)
- DNS TXT: Free (time: 1-72 hours)
- LinkedIn: Free (time: instant if employee)
- Instagram (free tier): Free (time: up to 30 days)

### Paid Verification Methods
- Meta Verified (Instagram/Facebook): $14.99-$349.99/month
  - Benefits: Blue checkmark, dedicated support, impersonation protection
  - Use case: High-profile venues/artists only

### Integration Development Timeline
- **Phase 1 (2-3 weeks):**
  - Google Place ID verification (including refresh system)
  - Spotify OAuth integration
  - DNS TXT verification system
  - Instagram manual verification (screenshot-based)
  - Basic manual upload for edge cases

- **Phase 2 (3-4 weeks):**
  - LinkedIn OAuth integration
  - Yelp integration
  - ISNI registry integration
  - Multi-ID trust scoring system
  - Dispute resolution workflow

- **Phase 3 (4-6 weeks):**
  - MusicBrainz API for deduplication
  - Bandsintown/Songkick cross-referencing
  - Multi-location/multi-brand management
  - Advanced analytics on verification success rates

## Technical Implementation Notes

### API Integrations Required
1. **Google Places API:** Place Details endpoint, Place ID refresh
2. **Spotify Web API:** Artist lookup, OAuth for verification
3. **Meta Graph API:** Instagram Business Account verification
4. **LinkedIn API:** Company Page verification
5. **ISNI API:** Registry lookup (if available)
6. **MusicBrainz API:** Artist/venue lookup, MBID resolution

### Database Schema Considerations
```javascript
Entity {
  id: UUID
  type: "venue" | "artist" | "organization"
  name: String
  canonicalIds: [
    {
      type: "google_place_id" | "spotify_uri" | "isni" | "domain" | "instagram" | etc.
      value: String
      verifiedAt: Timestamp
      expiresAt: Timestamp (for Google Place IDs)
      lastRefreshed: Timestamp
      verificationProof: Object // OAuth tokens, screenshot URLs, etc.
    }
  ]
  trustScore: Integer (0-100)
  verificationStatus: "unverified" | "pending" | "verified" | "disputed"
  ownedBy: User.id
  claimHistory: [
    {
      userId: UUID
      claimedAt: Timestamp
      verifiedAt: Timestamp
      canonicalIdsUsed: [String]
    }
  ]
}
```

### Refresh Job for Google Place IDs
```javascript
// Run quarterly
async function refreshExpiredPlaceIds() {
  const entities = await Entity.find({
    "canonicalIds.type": "google_place_id",
    "canonicalIds.lastRefreshed": { $lt: new Date() - 10_MONTHS }
  })

  for (const entity of entities) {
    const placeId = entity.canonicalIds.find(id => id.type === "google_place_id")

    // Email venue owner
    await sendEmail({
      to: entity.owner.email,
      subject: "Action Required: Refresh Google Place ID",
      body: `Your Google Place ID for ${entity.name} needs to be refreshed...`
    })

    // If >18 months old, mark as expired
    if (placeId.lastRefreshed < new Date() - 18_MONTHS) {
      entity.verificationStatus = "expired"
      await entity.save()
    }
  }
}
```

## Industry Trends and Future Considerations

### 2025 Metadata Revolution
- **ISNI Adoption:** Universal Music Group has assigned 100K+ ISNIs; YouTube now requires ISNIs for all creators
- **Metadata Hygiene:** Industry loses hundreds of millions annually to bad metadata; major push for standardization
- **AI Detection:** Emerging tools to detect metadata anomalies pre-publication
- **Blockchain Registries:** Nascent but growing - could provide immutable credit ledger

### Recommendations for Sonik
1. **Prioritize ISNI for artists** - align with industry direction
2. **Build robust refresh system for Google Place IDs** - critical weakness in current ecosystem
3. **Implement trust scoring** - reward entities with multiple verified IDs
4. **Plan for blockchain integration** - monitor industry developments
5. **Contribute to open standards** - consider MusicBrainz contributions for deduplication database

## Conclusion

**For Sonik's use case (ownership verification, not deduplication):**

1. **Venues:** Google Place ID (primary) with mandatory refresh system, Instagram URL (fallback)
2. **Artists:** ISNI (future-proof) or Spotify URI (current standard), Instagram URL (fallback)
3. **Organizations:** Domain verification (DNS TXT) as gold standard, LinkedIn as secondary

**Critical Success Factors:**
- Build automated refresh system for Google Place IDs (10-month reminder, 18-month expiration)
- Implement multi-factor trust scoring to incentivize multiple verifications
- Plan for ISNI adoption as music industry standard solidifies
- Design dispute resolution workflow from day one
- Do NOT scrape entities without at least one verifiable canonical ID

**Phased Rollout:**
- Phase 1: Google Place ID, Spotify URI, Domain verification, Instagram manual
- Phase 2: ISNI, LinkedIn, Yelp, multi-ID trust scoring
- Phase 3: MusicBrainz deduplication, advanced analytics, blockchain monitoring

## Sources

### Google Business Profile / Google My Business
- [Verify your business on Google - Google Business Profile Help](https://support.google.com/business/answer/7107242?hl=en)
- [Google Business Verification: Step-by-Step Guide for 2025 – Invoice Fly](https://invoicefly.com/academy/google-business-verification/)
- [How To Verify Your Google Business Profile (2025 Methods)](https://daltonluka.com/blog/google-my-business-verification)
- [How to verify your Google Business Profile in 2025](https://seranking.com/blog/verify-google-business/)
- [Required Documents for Google Business Profile Verification in 2025](https://digitalharvest.io/required-documents-for-google-business-profile-verification-in-2025/)

### Spotify for Artists
- [How to Get Verified on Spotify in 2025](https://dittomusic.com/en/blog/how-to-get-verified-on-spotify)
- [How to Get Verified on Spotify: A Step-by-Step Guide](https://playlistpush.com/blog/how-to-get-verified-on-spotify/)
- [Instant Spotify for Artists verification | DistroKid](https://distrokid.com/spotify/)
- [Getting access to Spotify for Artists - Spotify](https://support.spotify.com/us/artists/article/getting-access-to-spotify-for-artists/)
- [We're Simplifying Artist Verification – Spotify for Artists](https://artists.spotify.com/en/blog/simplifying-artist-verification)

### MusicBrainz
- [MusicBrainz Identifier - MusicBrainz](https://musicbrainz.org/doc/MusicBrainz_Identifier)
- [MusicBrainz Identifier - MusicBrainz Wiki](https://wiki.musicbrainz.org/MusicBrainz_Identifier)
- [Artist - MusicBrainz](https://musicbrainz.org/doc/Artist)
- [MusicBrainz API - MusicBrainz](https://musicbrainz.org/doc/MusicBrainz_API)

### Bandsintown
- [Verify an artist page | Bandsintown for Artists](https://help.artists.bandsintown.com/en/articles/7130879-verify-an-artist-page)
- [Claim an existing artist page | Bandsintown for Artists](https://help.artists.bandsintown.com/en/articles/7039351-claim-an-existing-artist-page)
- [What is the Bandsintown API? | Bandsintown for Artists](https://help.artists.bandsintown.com/en/articles/7053475-what-is-the-bandsintown-api)

### ISNI (International Standard Name Identifier)
- [What is an International Standard Name Identifier (ISNI)?](https://help.songtrust.com/knowledge/what-is-an-international-standard-name-identifier-isni)
- [Music Industry Code Identifiers — Henry Kapono Foundation | 501(c)(3)](https://www.henrykaponofoundation.org/resources/music-industry-code-identifiers)
- [YouTube adopts ISNI ID for artists songwriters](https://isni.org/page/article-detail/youtube-adopts-isni-id-for-artists--songwriters/)
- [ISNI - MusicBrainz](https://musicbrainz.org/doc/ISNI)
- [Universal Music adopts ISNI system, assigning ID numbers to songwriters and artists - Music Business Worldwide](https://www.musicbusinessworldwide.com/universal-music-adopts-isni-system-assigning-id-numbers-to-songwriters-and-artists/)
- [Music industry ISNI registrations now free and automated](https://isni.org/page/article-detail/music-industry-isni-registrations-now-free-and-automated/)

### Yelp
- [What is a claimed business? | Support Center | Yelp](https://www.yelp-support.com/article/What-is-a-claimed-business?l=en_US)
- [How to Add or Claim a Yelp Business Listing - BrightLocal](https://www.brightlocal.com/learn/how-to-add-or-claim-a-yelp-business-listing/)
- [The simple steps to claiming your Yelp Page](https://business.yelp.com/resources/articles/ultimate-guide-to-claiming-your-yelp-page/?domain=local-business)

### Songkick
- [Find your Songkick artist ID – Songkick Support](https://support.songkick.com/hc/en-us/articles/360012427414-Find-your-Songkick-artist-ID)
- [Verify your Songkick artist page – Songkick Support](https://support.songkick.com/hc/en-us/articles/360012784253-Verify-your-Songkick-artist-page)

### Instagram Verification
- [Verify Your Business on Instagram](https://help.instagram.com/369148866843923)
- [Requirements to apply for a verified badge on Instagram](https://help.instagram.com/312685272613322)
- [How to verify your business on Instagram to get a Blue Tick | Synup](https://www.synup.com/en/how-to/how-to-verify-your-business-on-instagram-to-get-a-blue-tick)
- [How to Get Verified on Instagram in 2026: Proven Tips - Shopify](https://www.shopify.com/blog/how-to-get-verified-on-instagram)

### DNS Domain Verification
- [What is a DNS TXT record? | Cloudflare](https://www.cloudflare.com/learning/dns/dns-records/dns-txt-record/)
- [Verify your domain with a TXT record - Google Workspace Admin Help](https://support.google.com/a/answer/16018515?hl=en)
- [How to verify the ownership of a domain using DNS (TXT record) | Snyk API & Web Help Center](https://help.probely.com/en/articles/3285635-how-to-verify-the-ownership-of-a-domain-using-dns-txt-record)
- [Verifying your domain with a TXT record | Cloud Identity](https://cloud.google.com/identity/docs/verify-domain-txt)

### LinkedIn
- [LinkedIn Page verification | LinkedIn Help](https://www.linkedin.com/help/linkedin/answer/a6275638)
- [How to Verify Your LinkedIn Company Page: A Step-by-Step Guide - B2B Growth Co](https://b2bgrowthco.com/linkedin-page-verification/)
- [Claim a LinkedIn Listing Page | LinkedIn Help](https://www.linkedin.com/help/linkedin/answer/a565267)
- [Request verification for your LinkedIn Page | LinkedIn Help](https://www.linkedin.com/help/linkedin/answer/a7174627)

### Google Place IDs
- [Place IDs | Places API | Google for Developers](https://developers.google.com/maps/documentation/places/web-service/place-id)
- [Place Details (New) | Places API | Google for Developers](https://developers.google.com/maps/documentation/places/web-service/place-details)
- [Place ID, Google ID, And CID: The Complete Guide to Google Maps Identifiers (2025) | Scrap.io](https://scrap.io/place-id-google-id-cid-complete-guide)

### Music Industry Identifiers (2025)
- [UMG just assigned 100K ISNI IDs: You need to get one too - Hypebot](https://www.hypebot.com/hypebot/2025/02/how-to-get-an-isni-id.html)
- [Metadata Matters in 2025: Credit Standards, ISRC Hygiene, and the Royalty Trails Artists Miss](https://www.studio814.net/post/metadata-matters-in-2025-credit-standards-isrc-hygiene-and-the-royalty-trails-artists-miss)
- [What is an Artist ID and Why Do I Need One? | Horus Music](https://www.horusmusic.global/news/what-is-an-artist-id-and-why-do-i-need-one/)
- [ISWC, ISRC, IPI, IPN, ISNI: Learn all about music unique identifiers](https://musicteam.com/music-unique-identifiers/)

### Event Ticketing Platforms
- [Ticketmaster: Buy Verified Tickets for Concerts, Sports, Theater and Events](https://www.ticketmaster.com/)
- [Eventbrite vs Ticketmaster: Choose the Right Ticketing Platform for Your Events - Evey](https://www2.eveyevents.com/blog/eventbrite-vs-ticketmaster/)
- [Top Concert Ticket Validation Systems](https://ticket-generator.com/blog/ticket-validation-system-for-concerts)
