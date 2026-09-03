# RAWWERS — MVP Screen Spec & Booking Flow

**Scope:** launch MVP only. Excluded: Studioverse, gear e-commerce storefront, Gear Loan Vault, Legacy Shoot, AI tooling, on-chain anything, client-side ecommerce beyond a balance display.

**Included:** photographer onboarding + RAW verification, 2 training modules with gate, booking, selection gallery, staged Stripe payments (charge minimum on accept, charge the difference on selection), delivery, messaging, mandatory review, $RAWW earning ledger.

**Design system:** near-black canvas, violet accent, editorial typography. Client app leads with imagery; Pro app leads with data density.

---

## PART 1 — CLIENT APP

### C1. Entry / Auth
- Full-bleed hero image from a real shoot on the platform
- Continue with email / Apple / Google
- Browsing allowed pre-auth; auth required at booking request

### C2. Discover (home)
- Search bar: niche + location + date
- Niche tiles (Event, Portrait, Newborn, Product…)
- "Available this weekend near you" row
- Featured photographers by tier

**Rule:** never show an empty state. If supply in the area is thin, widen radius silently and label distance.

### C3. Search results
- Card grid, image-first: hero shot, name, tier badge, niche, starting price/photo, distance, rating
- Filters: date available, tier, price ceiling, distance, niche
- Sort: relevance, rating, price. **Not** "cheapest first" as default — protects against a race to the bottom

### C4. Photographer profile
Everything the client needs to decide, in one screen:
- Portfolio gallery (RAW-verified work, per niche)
- Tier badge + one line explaining what that tier means
- Price: starting rate per photo + the decay curve shown as a simple table ("10 photos = €X, 25 = €Y, 50 = €Z")
- Turnaround time
- Travel radius / location
- Reviews (star breakdown, text, video reviews)
- Availability calendar
- **Book** CTA (sticky)

### C5. Booking request
- Date + time window
- Location (address or venue)
- Niche (locks pricing model: per-photo vs session)
- Expected photo count (drives the estimate, not binding)
- Brief: what the shoot is, what matters to the client
- Live estimate box updating as they change inputs

### C6. Payment
- Estimate breakdown: minimum 10 photos at rate = amount charged now
- Clear copy: *you're charged for the minimum today; if you select more photos later, you pay only the difference*
- Cancellation policy for this niche, stated plainly with the cutoff date
- Stripe payment sheet → **charge now** (base payment, not a hold)

### C7. Booking detail (status hub)
Single screen the client returns to. States shown as a progress rail:
Requested → Accepted → Confirmed → Shot → Gallery ready → Chosen → Delivered
- Photographer contact card
- Date, location, brief (editable until cutoff)
- Cancel button with current refund amount shown
- Message thread entry

### C8. Messages
- Per-booking thread, text + image
- No phone/email exchange in-app (light pattern filter, warning not block)

### C9. Selection gallery ← **core screen**
- Watermarked, low-res previews only
- Tap to select; selected count and **live running total** pinned to the bottom bar
- Minimum 10 enforced; "select all" available
- Decay curve made visible: "add 5 more → €X each instead of €Y"
- Selection window countdown (e.g. 14 days) shown
- **Confirm selection** → final charge

### C10. Final payment
- Line items: photos chosen, effective per-photo rate off the decay curve, total, amount already charged (base), difference charged now
- If the selection exceeds the package's included photos, the extras/upsell amount is a separate line and a separate charge

### C11. Mandatory review (gate to download)
- Step 1: multi-dimension stars — quality, communication, punctuality (seconds, taps only)
- Step 2 (optional, rewarded): written review, min length, earns $RAWW
- Step 3 (optional, higher reward): 30–60s video review + explicit consent toggle (profile only / profile + marketing)
- Reward amount is **identical regardless of rating given** — state this on screen
- Double-blind: nothing publishes until both sides submit or the window expires

### C12. Delivery
- Full-resolution downloads, individual + zip
- Expiry date for the download link
- $RAWW balance earned from the review, with a line on what it can be spent on

### C13. My bookings / account
- Upcoming, past, cancelled
- $RAWW balance
- Payment methods, receipts

---

## PART 2 — PHOTOGRAPHER APP (Pro)

### P1. Signup
- Email / Apple / Google
- Immediately into onboarding — no browsing

### P2. Onboarding — profile
- Name, base location, travel radius
- Niches (multi-select) — determines which caps and curves apply

### P3. Onboarding — gear registration
- Camera body: make, model, serial
- Lenses
- Equipment minimum check per niche; phone permitted where the niche allows
- **This record is what RAW verification is matched against**

### P4. Onboarding — RAW portfolio
- Upload N RAW files, shot on the registered body
- Client-side EXIF read + hash before upload; server re-verifies against registered gear
- Clear copy on why RAW is required (anti-fraud, not gatekeeping)
- → status: **Pending verification**

### P5. Verification pending
- What's happening, expected timeframe
- Training unlocked here so the wait is productive

### P6. Training (gate)
Two modules for MVP:
1. **Platform standards** — RAW retention, delivery timelines, no-show policy, dispute process
2. **Client handling & delivery** — confirming the brief, arriving prepared, expectation management, minimum selection, resolution/format rules

- Text or video content, short quiz per module, pass/fail
- Completion flag on the photographer record → **booking acceptance stays locked until passed**
- Recycling: a `training_valid_until` date; account locks to re-take when expired

### P7. Pricing setup
- Per niche: starting price per photo, must be ≤ tier cap
- Decay curve shown (fixed by platform, per niche) with a preview table of what a client will pay
- Estimated earnings after commission shown alongside

### P8. Availability calendar
- Block/unblock dates, set working hours, lead time required

### P9. Dashboard
- Current tier per niche + gigs completed / gigs needed to advance
- Rating floor status (progression needs gigs **and** a rating floor **and** low dispute rate)
- $RAWW balance + progress bar toward a redemption target
- Upcoming bookings
- Earnings this month

### P10. Requests inbox
- Incoming booking requests with brief, date, location, estimated value
- Accept / decline, with a response deadline (auto-decline on expiry)
- Declining too often affects ranking — state it

### P11. Booking detail
- Client brief, location with map, date
- Message thread
- **Mark as shot** action
- Cancellation with penalty shown

### P12. Upload & deliver
- Bulk upload
- Auto-generate watermarked low-res previews for the client gallery
- RAWs retained per platform standard (storage: originals to cold storage, previews hot)
- → status: **Awaiting selection**

### P13. Awaiting selection
- Which photos chosen so far isn't shown live (avoids anxiety); just the countdown to the client's deadline
- Auto-selection fallback if the client never chooses: top 10 by photographer's own ordering, at the minimum price

### P14. Earnings & payouts
- Held / clearing / paid out
- Stripe Connect onboarding and status
- Per-booking breakdown: gross, commission, net, $RAWW minted

### P15. $RAWW wallet
- Balance, earn history (proof-of-gigs entries)
- What it converts to — gear targets with progress bars
- **Redemption request** button (manual fulfilment behind the scenes at MVP)
- Non-transferable stated explicitly

---

## PART 3 — BOOKING FLOW (state machine)

```
DRAFT
  └─ client submits ──────────────► REQUESTED
                                      │
             photographer declines ◄──┤
             or response expires       │ photographer accepts
                                       ▼
                                   ACCEPTED
                                (base payment charged: minimum 10 photos × rate)
                                       │
                                       ▼
                                   CONFIRMED
                                       │
        ┌── client cancels ────────────┤
        │   (refund per cutoff)        │
        │                              │ shoot date passes
        │                              ▼
        │                        SHOOT_COMPLETED
        │                       (photographer marks)
        │                              │
        │                              ▼
        │                        GALLERY_UPLOADED
        │                              │
        │                              ▼
        │                       AWAITING_SELECTION ──── window expires ──┐
        │                              │                                 │
        │                              │ client selects ≥10              │ auto-select top 10
        │                              ▼                                 │
        │                          SELECTED ◄───────────────────────────┘
        │                     (final amount computed off the decay curve)
        │                              │
        │                              ▼
        │                      DIFFERENCE_CHARGED
        │              (only if amount_final > amount_minimum; decline →
        │               client retries the same PaymentIntent, gallery stays locked)
        │                              │
        │                              ▼
        │                       AWAITING_REVIEW
        │                    (download gated on review)
        │                              │
        │                              ▼
        │                          REVIEWED
        │                    ($RAWW minted both sides)
        │                              │
        │                              ▼
        │                          DELIVERED
        │                     (full-res unlocked)
        │                              │
        │           review window ends │ (or both parties reviewed)
        │                              ▼
        │                           CLOSED
        │                  (payout released to photographer,
        │                   reviews published, tier recalculated)
        │
        └──► CANCELLED  /  DISPUTED ──► manual resolution ──► CLOSED
```

### Timers to define
| Event | Suggested |
|---|---|
| Photographer response to request | 48h |
| Gallery upload after shoot | 7 days (niche-dependent) |
| Client selection window | 14 days |
| Review window before auto-publish | 14 days |
| Payout hold after CLOSED | 7 days |
| Download link validity | 90 days |

### Money at each stage
- **ACCEPTED** — base payment charged immediately: minimum 10 photos × the pro's entry rate for the niche (`StripePaymentKind.base`). Not a hold — a real charge.
- **SELECTED** — final amount computed from the niche's continuous per-photo decay curve (`compute_package_total`), not the old bracket/tier table. Selection above `included_photos` is a separate extras/upsell purchase.
- **DIFFERENCE_CHARGED** — only fires if `amount_final > amount_minimum`; charges just the gap as a second payment (`StripePaymentKind.difference`) via its own PaymentIntent. If it declines, the client retries the same PaymentIntent from the app — the gallery selection isn't considered paid, and delivery stays locked, until it succeeds.
- **CLOSED** — release net to photographer via Connect, mint $RAWW.

### Cancellation matrix (per niche)
| When | Refund |
|---|---|
| Before cutoff A (e.g. 14 days for events, 48h for portraits) | 100% |
| Between A and B | 50% |
| After B | 0%, photographer paid a call-out fee |
| Photographer cancels | 100% refund + ranking penalty |
| No-show either side | Dispute path |

### Dispute triggers
- Client rejects the gallery as unusable
- Photographer no-show
- Delivery past deadline
- Review flagged as retaliatory

At MVP: manual resolution by you, with the snapshot mechanics recording state at the moment of the dispute.

---

## BUILD ORDER

1. Auth + photographer onboarding + gear registration
2. RAW upload + verification (manual approval at MVP)
3. Training modules + gate
4. Pricing setup + availability
5. Client search + profile
6. Booking request + Stripe authorisation
7. Booking detail + messaging (both sides)
8. Upload + watermarked preview generation
9. Selection gallery + live total
10. Capture + review gate + delivery
11. $RAWW ledger + manual redemption
12. Payouts via Connect

Steps 1–10 are the minimum for one real booking to complete end to end. Step 11 can be a database table and an email until volume justifies more.
