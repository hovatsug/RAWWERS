# RAWWERS MVP Spec Audit — Implementation vs. Spec

Audited against `rawwers-mvp-screens-and-booking-flow.md`. Backend: `api/app/`. Frontend: `web/app/`, `web/lib/api/`. All findings verified against actual code (models, endpoints, services), not docs or test names.

**Legend:** 🔴 stub only · 🟠 partially implemented · 🟡 contradicts spec · 🟢 fully implemented

---

## 1. Pro onboarding — gear registration, RAW portfolio, verification

**Verdict: 🔴 Stub / 🟡 Contradicts spec.** The spec's central claim for this flow ("This record is what RAW verification is matched against," P3) has no implementation at all.

- **Gear registration**: a structured model with brand/model/serial number *does* exist — `GearItem` (`api/app/models/repair.py:71-89`, `category/brand/model/serial_number` fields) — but it belongs entirely to the repair/warranty-benefits subsystem (`api/app/api/v1/repairs.py`), never referenced from onboarding code. What onboarding actually writes to is `ProProfile.gear` (`api/app/models/admin.py:162`), an unstructured `JSON` dict with no schema — its only effect is a `+15` bump to a completeness score (`pro_onboarding.py:1108-1109`).
- **Equipment-minimum-per-niche check**: not found anywhere. No "phone permitted" logic exists (zero matches for `"phone"` as an equipment type in the backend).
- **RAW portfolio upload**: doesn't exist as a distinct concept. `MediaKind` only has `photo`/`video` (`api/app/models/media.py:14-16`) — portfolio uploads are handled as ordinary JPEGs (frontend literally hardcodes `content_type: "image/jpeg"`, `web/app/pro/profile/portfolio/page.tsx:11`). There is no EXIF reading anywhere in the codebase, client or server (zero matches for exif libraries in `api/` or `web/`).
- **Verification against registered gear**: cannot exist, since neither the gear-registration piece nor the RAW-upload piece is wired into onboarding, and no EXIF extraction exists to match against anyway.
- **"Pending verification"**: maps to `ProProfile.kyc_status` (`unsubmitted → pending → approved/rejected`). Exit from `pending` is **100% manual admin action** (`POST /admin/pros/{user_id}/kyc`, `admin.py:430-487`) — no automated check of any kind.
- **Frontend**: `web/app/pro/onboarding/page.tsx` is a 29-line raw-JSON dump of two API queries — no gear form, no RAW-specific upload control, no "pending verification" screen. `pro/profile/portfolio/page.tsx` is a hand-edit-JSON-and-submit debug tool, not a real upload UI.

---

## 2. Training gate

**Verdict: 🟡 Contradicts spec.** This is the highest-confidence finding in the audit: **training completion does not block booking acceptance.**

- A generic multi-course LMS exists (`Course`, `CourseModule`, `Enrollment`, `QuizAttempt` in `api/app/models/learning.py`) with working quiz pass/fail mechanics — but the two specific named modules ("Platform standards," "Client handling & delivery") don't exist anywhere. The word **"training" appears zero times** in the entire backend codebase (`api/app/`) — the concept is only realized as a generic, admin-authored course catalog.
- `accept_booking_request()` (`api/app/api/v1/pro_onboarding.py:821-972`) — the actual booking-accept endpoint — has exactly one eligibility gate: KYC status. Zero references to `Enrollment`, `Course`, or `is_mandatory` anywhere in this function.
- No `training_valid_until`-equivalent field exists. The closest analog, `CertificationRecord.expires_at` (`api/app/models/niche.py:95-106`), only feeds niche-tier *search ranking* score (`niche_skills.py:185-193`) — a Celery task recomputes it on expiry but never touches `is_accepting_bookings` or locks anything.
- Frontend: zero training/course UI exists anywhere in `web/app/` (confirmed by search across the whole app tree).

---

## 3. Pricing setup — per-niche cap enforcement, decay curve

**Verdict: 🟡 Contradicts spec.**

- `ProPackage.price` (`api/app/models/booking.py:34-52`) is set directly from the pro's request with only decimal rounding — **no tier-cap validation exists** for the base per-photo price. A tier-scoped cap (`ExtraImagePricingPolicy.unit_price_min/max`) does exist, but it only clamps the *extras/upsell* unit price, not the starting price the spec means (P7).
- **The decay curve is dead code.** `ExtraImagePricingPolicy.bulk_curve` (a JSON field, admin-settable) exists but is never read by `compute_extra_image_unit_price()` or anywhere else — confirmed by exhaustive grep, it appears only in the model and the admin CRUD endpoints. Actual extras pricing is flat linear multiplication (`unit_price × count`), not a decreasing-rate curve.
- No "estimated earnings after commission" preview exists during pricing setup. Commission (`platform_fee_bps`, default 20%) is computed, but only *after* a booking is created, not as a live preview.
- **Frontend bug, not just a gap**: `web/app/pro/profile/packages/page.tsx` posts a raw JSON payload with field names (`price_per_photo`, `min_photo_qty`) that don't match the backend schema (`price`, `included_photos`, `extra_photo_price`) — as wired today, this form likely can't successfully create a valid package.

---

## 4. Booking state machine

**Verdict: 🟠 Partially implemented / 🟡 Contradicts spec.** The spec describes one linear state machine; the code has several fragmented, weakly-connected ones that don't sync to each other.

**States that exist but the single machine doesn't:**
`GigStatus` has 15 values but several are dead code — `accepted`/`requested` are never referenced anywhere; `scheduled`/`shoot_done` are only used by an unrelated one-off "Legacy Shoot" product flow; `proofs_delivered`/`selection_pending`/`final_delivered` are **never assigned anywhere in the codebase**, only read. `BookingRequestStatus`, `ConfirmedSlotStatus`, `ProofGalleryStatus`, `SelectionStatus`, `DisputeStatus` are all separate enums on separate models that don't reference each other's state.

`gig_state.py`'s `ALLOWED_TRANSITIONS` guard dict covers only 4 of the 15 `GigStatus` values (`payment_pending`/`paid`/`refunded`/`disputed`) — everything else, including the admin-only `completed` transition, bypasses this guard entirely via direct `gig.status = ...` mutation in `admin.py`.

**Timers — cross-cutting critical finding**: there is **no Celery Beat/cron scheduler configured anywhere in this repository** (`celery_app.py` never sets `beat_schedule`; no `beat` service in any `docker-compose*.yml`; no cron/k8s CronJob files anywhere). Every timer below exists as *code that would work if invoked*, but nothing in the repo actually invokes it on a schedule:

| Timer | Spec | Code | Status |
|---|---|---|---|
| Photographer response | 48h | **24h**, hardcoded (`pro_onboarding.py:766`) | 🟡 wrong value, and enforcement is a manual admin-only HTTP endpoint, not automatic |
| Gallery upload after shoot | 7 days | `finals_sla_days` (default 7) exists but is only read during manual dispute resolution | 🟠 field exists, nothing proactively acts on it |
| Client selection window | 14 days | **Not found** — no deadline field exists on `ProofGallery` at all | 🔴 |
| Review window before auto-publish | 14 days | **Not found** — reviews publish immediately on submission | 🟡 |
| Payout hold after closed | 7 days | Correctly computed (`available_at = now + 7d`); Celery task exists (`run_settlement_scan_task`) | 🟠 logic correct, never triggered (no scheduler) |
| Download link validity | 90 days | **Not found** — `GigMediaEntitlement.valid_until` is always `None` (never expires) in the gig/download flow; only used in an unrelated subsystem (Studioverse) | 🔴 |

**Cancellation refund matrix**: not found as a functioning system. A `CancellationPolicySnapshot` is written once at booking-confirm time with hardcoded values (`cancel_before_hours_no_fee: 48`, `partial_fee: 24`) — grep confirms these are **never read anywhere**. Actual refund handling instead routes through a global (not niche-varying) dispute-category policy table, mostly requiring manual admin review.

**Dispute handling** is, by contrast, the most solidly implemented piece of this whole flow: full model/states, client endpoints, an admin resolution endpoint, and a real auto-escalation function all exist and are correctly wired together (modulo the same missing-scheduler problem for the auto-escalation timer).

---

## 5. Escrow

**Verdict: 🟡 Contradicts spec — fundamental architecture mismatch**, not a partial gap.

- Booking acceptance creates **no** Stripe PaymentIntent at all — it's created later, client-initiated, via a separate endpoint.
- **No `capture_method="manual"` anywhere in the codebase** (grepped all 5 `PaymentIntent.create` call sites). Stripe's default is automatic capture — meaning the base amount is captured immediately on payment, not held/authorized as the spec's entire premise requires ("funds are held, not paid," C6).
- Since no decay curve exists (§3), "capture on selection, computed from the decay curve" can't exist either. What happens instead: the full flat price is captured upfront, and selection-time "extras" are handled as an entirely **separate, new PaymentIntent** for a flat per-unit overage — not a difference charge against the original authorization (no `PaymentIntent.modify`/increment-authorization call exists anywhere).
- **Notable bug**: the "included photos" download entitlement is granted **unconditionally at selection-submit time**, before the extras PaymentIntent's outcome is known (`proof_galleries.py:367-377`) — so a client keeps included-tier download access even if their extras charge is later declined. The gallery itself never gets an explicit "failed" state; it just stalls.
- Decline handling for the *initial* payment: the webhook correctly flips `StripePayment.status = failed`, but `GigStatus` has **no failed/declined value at all** — the gig just sits in `payment_pending` indefinitely with no automatic resolution path.

---

## 6. Selection gallery

**Verdict: 🟢 Backend watermarking is genuinely solid / 🟡 Contradicts spec everywhere else.** This is the spec's own "core screen" (C9) and the client-facing implementation of it does not exist.

- **Watermarked previews are real** — server-side Pillow compositing (`_draw_watermark`, `api/app/tasks/media_tasks.py:308-338`), text overlay with optional pro-name branding, and it's enforced as a precondition before a photo can even be added to a gallery. This is the one unambiguous "fully implemented, exceeds a stub" finding in the whole audit.
- **Minimum 10 is not enforced anywhere.** `save_selection`/`submit_selection` perform zero count validation — a selection of 0 or 1 photos submits successfully. Direct contradiction of C9's explicit "Minimum 10 enforced."
- **The live running total is not a real feature.** `web/app/client/gigs/[id]/proofs/page.tsx` — the actual selection screen — is a stub: `selected` state hardcoded to `12`, `included`/`perExtra` hardcoded to `10`/`7`, one numeric `<Input>` field, **no photo grid or thumbnails rendered at all**, and **no calls to any backend endpoint whatsoever** (not even to fetch the real gallery). There is nothing to "tap to select" — the entire watermarked-preview-gallery UX the spec describes doesn't exist on this screen.
- Select-all: not found (unsurprising, given there's no gallery grid to select from).
- Selection window countdown: not found — no deadline field exists on the model; only two fixed, best-effort reminder notifications at +24h/+72h post-publish, and even those are explicitly stubbed (`# Placeholder send... Future slices can integrate email/push`, `reminders.py:93`).

---

## 7. Review gate

**Verdict: 🟡 Contradicts spec on every specific claim tested.**

- **Download is not gated on review.** The full-resolution download entitlement is granted at selection-submit time, fully independent of review submission — `media_rights.py`'s download endpoint has zero references to the `Review` model anywhere.
- **Not double-blind.** `Review.status` defaults to `published` immediately at creation and is instantly visible via the public reviews endpoint. There's no pending/awaiting-counterpart state, no reveal window — and structurally, the system only supports one review per gig (client→pro); there's no "pro reviews client" capability at all, so a double-blind exchange isn't even architecturally possible today, let alone gated.
- **No multi-dimension ratings.** `Review` has a single overall `rating` (1-5) plus free-form `tags` — no separate quality/communication/punctuality scores as C11 step 1 describes.
- **No consent toggle.** `video_media_asset_id` exists on the model, but there's no consent field (profile-only vs. profile+marketing) anywhere, despite C11 step 3 explicitly requiring it.
- **Reward is not rating-independent**, contrary to the spec's explicit on-screen promise ("Reward amount is identical regardless of rating given," C11). The actual $RAWW multiplier depends on the *pro's* rolling average rating tier (`rating_curve` thresholds 4.0/4.5/4.8 → 0.9×/1.0×/1.1×) — so it does fluctuate with rating, just indirectly.
- **Worth flagging separately**: the spec frames C11/C12 as the *client* earning $RAWW for reviewing ("earns $RAWW," "$RAWW balance earned from the review"). In the code, the review-posted mint credits the **pro being reviewed**, not the client who wrote it. This is either a spec-writing ambiguity or a real design mismatch worth resolving explicitly.

---

## 8. $RAWW ledger

**Verdict: 🟠 Partially implemented — minting/clawback backend is strong; redemption model contradicts spec.**

- Minting infrastructure is genuinely sophisticated: issuance rules, multiplier policy (tier/rating/dispute/refund-penalty factors), per-scope daily/weekly/monthly/global caps, self-dealing and abuse-signal blocking, idempotency keys — all real and reasonably tested.
- Minting triggers on `gig.delivery_confirmed` (fires automatically when the client submits selection with no unpaid extras — a reasonable proxy for completion) and `gig.completed` (admin-only manual trigger, same gating issue as §4/§9).
- **Clawback is solidly implemented**: both manual admin clawback (with a balance-floor protection check) and automatic reversal-on-refund exist and are covered by tests.
- **Non-transferability is correctly enforced** — this is a place the code matches the spec exactly. Thorough negative search (endpoint names, the `RewardEntryType` enum, every balance-mutating function signature) confirms there is no user-to-user transfer path anywhere. Worth stating explicitly since "nothing exists" claims are easy to get wrong — this one is well-verified.
- **Redemption contradicts the spec's model.** The spec describes a "Redemption request button (manual fulfilment behind the scenes at MVP)" converting toward gear targets with progress bars (P15). The actual implementation (`POST /rewards/spend`) is a fully **automated, self-service discount-on-payment** system — it immediately deducts balance and applies a computed EUR discount to a Stripe payment. There's no request-queue-for-manual-fulfillment flow and no gear-target/progress-bar redemption path found anywhere.
- Not directly audited: the dedicated P15 "$RAWW wallet" screen (gear-target progress bars specifically). The one pro earnings screen found (`web/app/pro/wallet/page.tsx`) surfaces **EUR** earnings/payouts, not a RAWW-specific balance/redemption UI — flagging this as a coverage gap in this audit rather than asserting a verdict without direct evidence.

---

## 9. Payouts via Connect

**Verdict: 🟡 Contradicts spec (no real Connect integration) / 🟠 Partial (money movement itself is solid) / 🔴 Stub (frontend, plus a real bug).**

- **No Stripe Connect onboarding integration exists at all** — no `Account.create`, no `AccountLink.create` anywhere in the codebase. The pro just self-reports a `stripe_connect_account_id` and a `status` via a raw `PUT /pro/payouts/account` endpoint. There's no `account.updated` webhook handler, so the "verified" status is whatever the pro claims, never reconciled against Stripe's actual `charges_enabled`/`payouts_enabled`.
- **Actual money movement is real and correct**: `stripe.Transfer.create(...)` to the connected account (`payouts.py:456-462`), properly gated on `status == active && payout_method == stripe_connect`, with a sensible manual-payout fallback path for `bank_manual` accounts.
- Gross/commission/net is computed via **two independent, slightly-divergent fee code paths** (`settings.platform_fee_bps` at booking-accept time vs. `PlatformFeePolicy.fee_percent_gigs` at earnings-entry time) — both currently default to 20%, but they're architecturally duplicated rather than a single source of truth.
- The 7-day hold is correctly computed but — same as §4 — never actually fires, since there's no scheduler triggering `run_settlement_scan_task`.
- **Frontend has a genuine functional bug, not just a spec gap**: `web/app/pro/wallet/page.tsx` reads `available_balance`/`available` keys off the balance response, but the real schema returns `pending_eur`/`available_eur`/`held_eur`/`reserved_eur`/`withdrawable_eur` — meaning the balance display would render `"-"` against the actual API today. No held/clearing/available breakdown is shown at all, and there's no Connect-onboarding-status UI or link — payout account/request forms are raw JSON textareas.

---

## Where the code is right and the spec may be wrong

Honest accounting: across all nine flows, the overwhelming pattern is the code falling short of the spec, not the spec being wrong. I looked hard for the reverse and found two legitimate candidates, plus one clean confirmation:

1. **Escrow capture timing (§5) — the spec's mechanism may not survive contact with Stripe.** Stripe's manual-capture authorization holds expire — typically around 7 days for card payments (up to longer for some networks, but not indefinitely). The spec's model (authorize on accept, capture only after shoot + a 14-day selection window) could exceed that window for any booking made more than roughly a week ahead of the shoot date, which is presumably common for events. The code's actual approach — capture the base amount in full upfront, then run selection-time overage as a separate new charge — sidesteps that expiry problem entirely, even though it abandons the "held, not paid" promise made to clients in C6. This is worth an explicit product decision rather than treating it as a plain implementation gap: either the copy in C6 needs to change to match a capture-now model, or the team needs a different technical mechanism (e.g., re-authorization reminders, or accepting the Stripe hold-window constraint into the booking-lead-time design).

2. **RAWW minting on `delivery_confirmed` vs. requiring full gig closure (§8).** The spec's flow implies minting only happens once the whole state machine reaches `CLOSED`. The code's choice to also mint on the client's own selection-submission action is arguably more robust — it's a real, automatic client-driven signal, rather than depending on an admin manually flipping a status flag (which, per §4/§9, is currently the *only* way `GigStatus.completed` is ever reached). This partially compensates for the broken "auto-completion" path, though it's a workaround for a gap rather than a deliberate design win.

3. **Non-transferability (§8) — a clean confirmation, not a disagreement.** The spec requires $RAWW to be explicitly non-transferable, and the code delivers this correctly and verifiably (no transfer path exists anywhere in the codebase). Not a place they disagree, but worth stating plainly since it's the one place a "nothing exists" claim in this audit is fully backed by an exhaustive negative search rather than an inference.

Everywhere else — the 24h vs. 48h response window, the missing minimum-10 enforcement, the absent decay curve, the non-double-blind reviews, the self-reported Connect status — the spec is the more defensible position and the code needs to move toward it, not the other way around.

---

## The one cross-cutting finding that affects almost everything

**There is no scheduler in this repository at all** — no Celery Beat, no cron, no equivalent. Every time-based rule in the spec (response deadlines, selection windows, review auto-publish, payout holds, SLA lateness checks, dispute auto-escalation) has correct-looking code sitting behind it, but nothing in the repo actually invokes any of it on a recurring basis. This single gap is arguably higher-priority to close than any individual flow above, since it silently neuters timers that otherwise look implemented.
