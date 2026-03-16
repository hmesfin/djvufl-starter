# Real Estate Agent Marketplace -- Design Document

**Date:** 2026-03-16
**Status:** Approved

## Problem Statement

Real estate agents work within broker group silos and rely on word-of-mouth to find other professionals. Common scenarios that lack good solutions:

- Needing another agent to cover a showing across town when you have a scheduling conflict
- Finding available, trustworthy contractors/professionals for client referrals

There is no centralized, verified platform for real estate professionals to find and hire each other for specific jobs.

## Solution Overview

A two-sided marketplace for real estate agents to find, vet, and hire other verified agents for gig work (showings, open houses, etc.). The platform's key differentiator is **100% license verification** -- every agent on the platform is verified against the MN Commerce Department before they can participate.

## Scope

### MVP Target

- **Users:** Real estate agents only (contractors, mortgage, insurance, appraisers are future phases)
- **Geography:** Minneapolis/St. Paul metro area pilot
- **Platform:** Django API + Vue.js frontend + Flutter mobile

### Core Features

1. Agent profiles with MN license verification
2. Agent directory with search/filter (service area, rating, response time)
3. Gig creation with both post-and-wait and search-and-invite workflows
4. In-app messaging (gig-contextual)
5. Stripe Connect payments with platform fee
6. Bidirectional reviews after gig completion

### Deliberately Out of Scope

- Calendar sync / availability slots
- Background checks (beyond license verification)
- Automated dispute resolution (manual via Django admin)
- Multi-state licensing (MN only, architected for expansion)
- Social features (feed, posts, network)
- Agent teams / brokerage accounts
- Escrow / milestone payments
- SEO / public profiles

## Data Model

### ProfessionalProfile (1:1 with User)

| Field | Type | Notes |
|-------|------|-------|
| user | OneToOne → User | Existing user model |
| license_number | CharField | MN Commerce Dept license ID |
| license_status | CharField | `pending_verification`, `verified`, `rejected`, `expired` |
| license_expiry | DateField | For proactive re-verification |
| service_areas | M2M → ServiceArea | Neighborhoods/zip codes they cover |
| specializations | ArrayField/Choices | residential, commercial, buyer's, listing |
| bio | TextField | Free text |
| average_rating | DecimalField | Denormalized from reviews |
| average_response_time | DurationField | Calculated from messaging patterns |
| is_available | BooleanField | "I'm taking gigs" toggle |
| stripe_connect_account_id | CharField | For payouts |
| verified_at | DateTimeField | When verification was confirmed |
| verified_by | FK → User | Admin or "system" for automated |
| last_reverification_check | DateTimeField | Nightly job timestamp |
| rejection_reason | TextField | If rejected, why |

### ServiceArea

| Field | Type | Notes |
|-------|------|-------|
| name | CharField | e.g., "Downtown Minneapolis", "Edina" |
| zip_codes | ArrayField | Zip codes in this area |
| metro | FK → Metro | "Minneapolis-St. Paul" for now |

### Metro

| Field | Type | Notes |
|-------|------|-------|
| name | CharField | e.g., "Minneapolis-St. Paul" |
| state | CharField | e.g., "MN" |

### Gig

| Field | Type | Notes |
|-------|------|-------|
| posted_by | FK → ProfessionalProfile | Agent A |
| assigned_to | FK → ProfessionalProfile | Agent B, nullable until accepted |
| title | CharField | "Showing at 123 Main St" |
| description | TextField | Details, instructions, client info |
| location_address | CharField | Street address |
| location_lat | DecimalField | For distance calculations |
| location_lng | DecimalField | For distance calculations |
| service_area | FK → ServiceArea | |
| scheduled_date | DateField | |
| scheduled_time | TimeField | |
| budget_range_min | DecimalField | Agent A's range |
| budget_range_max | DecimalField | |
| agreed_price | DecimalField | Final negotiated amount |
| status | CharField | See lifecycle below |
| gig_type | CharField | `showing`, `open_house`, `inspection_accompaniment`, etc. |

### GigInvitation

| Field | Type | Notes |
|-------|------|-------|
| gig | FK → Gig | |
| invited_agent | FK → ProfessionalProfile | |
| proposed_rate | DecimalField | Agent B's counter-offer |
| message | TextField | Cover note |
| status | CharField | `pending`, `accepted`, `declined`, `withdrawn` |

### Review

| Field | Type | Notes |
|-------|------|-------|
| gig | FK → Gig | One review per gig per direction |
| reviewer | FK → ProfessionalProfile | |
| reviewee | FK → ProfessionalProfile | |
| rating | IntegerField | 1-5 |
| comment | TextField | |
| is_from_poster | BooleanField | Did Agent A review Agent B? |

### Conversation

| Field | Type | Notes |
|-------|------|-------|
| participant_1 | FK → ProfessionalProfile | |
| participant_2 | FK → ProfessionalProfile | |
| gig | FK → Gig | Optional, nullable |

### Message

| Field | Type | Notes |
|-------|------|-------|
| conversation | FK → Conversation | |
| sender | FK → ProfessionalProfile | |
| body | TextField | |
| read_at | DateTimeField | Nullable |

### Payment

| Field | Type | Notes |
|-------|------|-------|
| gig | OneToOne → Gig | |
| stripe_payment_intent_id | CharField | |
| amount | DecimalField | |
| platform_fee | DecimalField | |
| status | CharField | `pending`, `captured`, `released`, `refunded`, `failed` |

## Gig Lifecycle

```
draft → posted → invited → negotiating → accepted → in_progress → completed
                                                                  ↘ disputed
           ↘ cancelled (from any state before in_progress)
```

1. **draft** -- Agent A creates gig, saves without posting
2. **posted** -- Gig visible in marketplace
3. **invited** -- Agent A sends invitations to specific agents
4. **negotiating** -- Invited agents respond with proposed rates
5. **accepted** -- Agent A accepts a proposal; payment captured; others auto-declined
6. **in_progress** -- Auto-transitions at scheduled time or manual trigger
7. **completed** -- Agent B marks done, Agent A confirms (or auto-confirm after 48hrs). Payment released. Reviews prompted.
8. **cancelled** -- Either party, before `in_progress`. Refund: full if >24hrs, 50% if <24hrs.
9. **disputed** -- Agent A unsatisfied. Manual resolution via Django admin.

## Verification System

### Phase 1: Manual (Launch)

- Agent enters license number at signup
- Profile created as `pending_verification`
- Pending agents can browse but cannot post gigs, accept invitations, or message
- Admin manually verifies against MN Commerce Department license lookup
- Agent notified of verification result via email

### Phase 2: Automated (Target)

- Celery task fires on license number submission
- Scrapes/queries MN Commerce Department lookup
- Auto-verifies if: license exists, name matches, status active, not expired
- Flags for manual review if ambiguous
- Nightly re-verification job checks all verified agents' licenses remain active
- Auto-suspends if license expires or is revoked

### Zero Tolerance Policy

- No "partially verified" state -- verified or not
- Verified badge on profile
- All transactional features (gigs, messaging, payments) gated behind verification

## Django App Structure

### New Apps

| App | Responsibility |
|-----|---------------|
| `professionals` | ProfessionalProfile, ServiceArea, Metro, verification logic |
| `gigs` | Gig, GigInvitation, gig lifecycle state machine |
| `reviews` | Review model, rating aggregation |
| `messaging` | Conversation, Message |
| `payments` | Payment model, Stripe Connect integration, webhooks |

### Existing Apps

- **`users`** -- unchanged, handles auth/registration/OTP
- **`projects`** -- remove (demo scaffolding from starter template)

### App Boundaries

Each app owns its domain. Cross-app references via FK only, no importing business logic across apps.

## API Endpoints

```
/api/professionals/              -- list/search verified agents
/api/professionals/:uuid/        -- profile detail
/api/professionals/me/            -- own profile management
/api/service-areas/               -- list available service areas

/api/gigs/                        -- list/create gigs
/api/gigs/:uuid/                  -- gig detail + status transitions
/api/gigs/:uuid/invitations/      -- invite agents, manage responses

/api/conversations/               -- list conversations
/api/conversations/:uuid/messages/ -- message thread

/api/reviews/                     -- create/list reviews

/api/payments/webhook/            -- Stripe webhook endpoint
/api/payments/:gig_uuid/          -- payment status for a gig
```

## Search & Discovery

### Filters

- Service area (primary)
- Availability toggle
- Minimum rating
- Specialization
- Response time

### Implementation

Django ORM + PostgreSQL for MSP pilot. No Elasticsearch or PostGIS needed at this scale.

Denormalized rating and response time fields make filtering fast. Upgrade path: PostGIS for radius search when expanding beyond MSP, Elasticsearch for full-text at thousands of profiles.

## Payments (Stripe Connect)

### Setup

- Platform Stripe account (yours)
- Connected accounts via Stripe Connect Express (each verified agent)
- Agents onboard through Stripe-hosted UI (KYC/tax handled by Stripe)

### Flow

1. Gig accepted → PaymentIntent created for agreed price
2. Agent A's card charged, funds held
3. Gig completed → Transfer to Agent B's connected account minus platform fee
4. Standard 2-day payout to Agent B's bank

### Platform Fee

- Configurable percentage (5-10% starting point)
- Deducted via Stripe `application_fee_amount`

### Cancellation Refunds

- >24hrs before gig → full refund
- <24hrs → 50% refund (configurable)
- Disputed → funds held until manual resolution

### Webhooks

- `payment_intent.succeeded` / `payment_intent.payment_failed`
- `account.updated`
- `transfer.created` / `transfer.failed`

## Messaging

- Lightweight coordination messaging, not a chat app
- Conversations link two agents, optionally tied to a gig
- Verification-gated (only verified agents can message)
- Frontend polls every 30 seconds (websockets later)
- Email notification if message unread after 5 minutes (Celery delayed task)
- No group chat, attachments, editing, or real-time indicators in MVP

## Frontend (Vue.js)

### New Views

- Professional onboarding (post-registration)
- Agent directory (search/filter, agent cards)
- Agent profile (full detail, reviews, "Invite to Gig")
- My profile (edit info, availability toggle, Stripe Connect link)
- Gig management (create/edit, my posted/accepted gigs, status timeline)
- Invitations (incoming/outgoing with status)
- Conversations (inbox, message thread)
- Dashboard (active gigs, pending invitations, unread messages, earnings)

## Mobile (Flutter)

- Same feature set as web, same API
- Prioritizes on-the-go usage: push notifications, quick availability toggle, gig detail with map
- Web-first for MVP, mobile follows

## Revenue Model

1. **Subscription** -- monthly/annual fee for platform access
2. **Transaction fee** -- percentage of each gig payment (via Stripe Connect)
3. **Freemium tier** -- free to browse, pay for premium features (priority placement, analytics, unlimited gigs)

## Technical Decisions

- Extend existing Django+Vue+Flutter stack (monolithic, Approach A)
- PostgreSQL for all data (no additional data stores for MVP)
- Celery for async tasks (verification, notifications, re-verification jobs)
- Redis for Celery broker (already in stack)
- Stripe Connect Express for payments
- Django ORM for search (no Elasticsearch/PostGIS at MSP scale)
