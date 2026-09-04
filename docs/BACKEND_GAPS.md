# Backend gaps

Confirmed backend behavior that the Flutter rebuild (F-0–F-8) needs to design around or route around, rather than something to silently paper over client-side. Entries here are verified against the running API or its source, not assumed. Append as F-6/F-7 discovery turns up more (the original task brief calls for several: canonical chat route family, review-gates-download, `GET /v1/client/bookings` — none of those are independently confirmed yet, so they're not listed below until they are).

## `complete_photo_upload` is not idempotent

`POST /v1/media/photos/{media_asset_id}/complete` only succeeds while the asset's status is still `uploading` or `created`; it transitions to `processing` on success and rejects a second call with a 409 `invalid_state` (`api/app/api/v1/media.py`, `complete_photo_upload`).

**Why this matters on mobile specifically:** the classic bad-signal failure mode — the request reaches the server, the server processes it and returns 200, but the client never receives the response (connection drops, app backgrounds, timeout fires first) — leaves the client believing the call failed. If the app auto-retries in that state, the retry 409s even though the upload actually succeeded. Confirmed in F-3: `PhotoUploadService` deliberately calls `complete` at most once and never auto-retries it, surfacing the failure to the caller instead. A real fix (an idempotency key, or accepting a repeat call in the already-`processing`/already-`ready` state as a no-op success) would need to happen server-side; not in scope for the Flutter rebuild.

## No email is ever delivered — every mail path is console-only, and the outbox is never drained on a schedule

Found in F-5 by running the real app against the local backend: `POST /v1/auth/verify-email/request` returns **204 and nothing arrives**. The endpoint is not broken — it does exactly what it should, and then the mail dies in two separate places downstream. Both are verified in source, not inferred.

**1. No mail provider is configured.** `get_mail_provider()` (`api/app/services/mail.py:58`) unconditionally returns `ConsoleMailProvider()` — there is no settings switch, env var, or branch that selects a real transport. Every send in the system (`send_verification_email`, `send_password_reset_email`, `send_template_email`) therefore writes to the log and returns success. Nothing distinguishes "sent" from "printed".

**2. Nothing drains the outbox periodically.** `_create_email_verification` (`auth_service.py:92`) correctly enqueues an `email.verify.send` outbox event, and `dispatch_outbox_events` (`api/app/tasks/outbox_tasks.py`) correctly dispatches it to the mail provider. But that task is **not in `celery_app.conf.beat_schedule`** — the only callers are the Stripe and Mux webhook handlers (`api/app/api/v1/webhooks.py`, `.delay()`), plus tests. `docker-compose.yml` also runs a `worker` service but no `beat` service, so even the sweeps that *are* scheduled (booking-request expiry, payout-hold release, dispute escalation, stuck bookings) never fire locally. So an auth email sits pending until an unrelated payment webhook happens to kick the queue.

**3. This is not only email — in-app notifications go through the same undrained outbox.** `enqueue_notification` (`api/app/services/notifications.py:245`) does *not* write a notification row synchronously; it enqueues a `notify.create_inapp` outbox event. So `GET /v1/me/notifications` returns an empty list for the same reason, and the in-app bell is as silent as the mailbox. Anything built on top of the notification feed inherits this.

**Why this blocks the end-to-end run rather than just verification UX:** booking requests auto-decline after 48h. A photographer who never learns a request arrived cannot act inside that window, so the single most time-critical path in the product depends on notification channels that currently deliver nothing — neither email nor in-app. This is not an F-5/F-6 blocker for the auth work — email verification gates no API, and the apps are built to work without it — but the product cannot be exercised end to end until a provider is configured *and* the outbox is drained on a schedule (`dispatch_outbox_events` added to `beat_schedule`, plus a `beat` service in compose). All three fixes are server-side and outside the Flutter rebuild's scope.

## ~~No list endpoints exist for booking requests, gigs, or bookings~~ — FIXED in `b91ee8ba`

**Resolved.** `GET /v1/booking-requests`, `GET /v1/gigs` and `GET /v1/client/bookings` were added, with keyset cursor pagination. Kept here because the original finding explains why those routes look the way they do, and because the two entries below qualify the fix. Original finding follows.

Verified against the **full** (unfiltered) OpenAPI schema in F-6 discovery, so this is not an artifact of the MVP tag filter. The API exposes only fetch-by-id and actions:

- Booking requests: `GET /v1/booking-requests/{request_id}` — no `GET /v1/pro/booking-requests`, no collection route of any kind.
- Gigs: `GET /v1/gigs/{gig_id}` — no `GET /v1/pro/gigs`.
- Client bookings: `GET /v1/client/bookings/{booking_id}` — no list. Independently corroborated: `web/lib/api/booking.ts:28-33` already carries a "BACKEND GAP, reported not fixed" comment saying the same thing, and its `clientBookings()` wrapper calls a route that does not exist and always fails.

Payouts and earnings are the exception and *do* have collection routes (`GET /v1/pro/payouts`, `GET /v1/pro/earnings/ledger`), so this is a specific omission rather than a general API style.

**What it blocks:** any screen whose job is "here is your queue of work" — the pro app's Requests, Gigs, and Today tabs, and the client app's bookings list. A pro cannot enumerate the requests awaiting them, which is the same 48h-window problem from the notification gap arriving by a second independent route. There is no client-side workaround: an id-only API cannot be turned into a list, and the notification feed that might have supplied the ids is itself empty (see above). Adding the list routes is a server-side task.

## ~~`GET /v1/me/notifications` paginates on a timestamp alone, so it skips and repeats rows~~ — FIXED in `029e1b38`

**Resolved.** `list_notifications` now uses the shared `(created_at, id)` keyset helper, and an unparseable cursor returns 422 across every endpoint using it rather than silently re-serving page one. Kept for the reasoning. Original finding follows.

`list_notifications` (`api/app/services/notifications.py:387`) uses `created_at` as its entire cursor: it returns `rows[-1].created_at` as `next_cursor` and filters the next page with `created_at < cursor`. That ordering is not total. When two notifications share a `created_at` — and they routinely will, because `dispatch_outbox_events` processes a batch inside one transaction, so every notification in a batch lands on effectively the same timestamp — the rows tied at the page boundary are dropped: the strict `<` skips past all of them, not just the one already returned. The `except ValueError: pass` on an unparseable cursor silently ignores the filter entirely and re-serves page one, which is the duplicate half of the same bug.

**Why it matters now specifically:** until `dispatch_outbox_events` was put on `beat_schedule` (`b91ee8ba`) the notification feed was always empty, so this could never fire. Now that the outbox actually drains, the feed fills in batches — exactly the shape that triggers ties — and a photographer paging their notifications can silently miss one. Given the 48h response window, the notification that goes missing may be the booking request itself.

The fix is the keyset helper already in the codebase: `app.services.pagination` orders on `(created_at, id)` and is used by the three list endpoints added in the same commit. Retrofitting `list_notifications` onto it is a small, contained change, deliberately not bundled into that commit — it changes an existing endpoint's cursor format, which is a separate decision from adding new routes.

## Delayed-notification payment methods are not handled (mitigated for launch by Stripe dashboard config)

Surfaced in F-6 when `8a946064` switched every PaymentIntent to `automatic_payment_methods`. Automatic lets Stripe offer whatever suits the buyer's region, which in Europe includes **delayed-notification** methods — Multibanco, SEPA debit, some bank redirects — where the customer completes their side and the payment clears hours or days later. The code assumes payment either succeeds or fails promptly.

**Not currently reachable:** delayed-notification methods are disabled in the Stripe dashboard for launch, so nothing below can fire. That is configuration, not code — re-enabling any such method in the dashboard arms all of it with no deploy.

### 1 + 2. No `payment_intent.processing` handling, and the payment follow-up therefore nags people who have already paid

These are one fix, not two, and would be implemented together.

`api/app/api/v1/webhooks.py` handles `payment_intent.succeeded`, `payment_intent.payment_failed` and `payment_intent.canceled`. It does **not** handle `payment_intent.processing`, which is the event that says "the customer has paid and it is clearing". Without it there is no state distinguishing *hasn't paid* from *paid, awaiting clearance* — the gig sits at `payment_pending` for both, and neither the photographer nor the client can tell which.

That missing distinction is exactly why the follow-up misfires: `payment_pending.client` sends an in-app "Complete payment — your booking is waiting for payment" at 60 minutes and again at 24 hours (`api/app/services/followups.py:50-61`). Multibanco routinely takes longer, so a client who has already paid is told twice that they haven't. The follow-up cannot be gated correctly until the `processing` state exists to gate it on — hence one fix: record the processing state, then trigger the follow-up on "not yet initiated" rather than "not yet succeeded".

The non-broken half, for the record: `map_intent_status` already maps Stripe's `processing` to `pending`, and `payment_intent.succeeded` is handled, so a payment that clears days later *does* correctly move the gig to `paid`. Nothing is lost or corrupted; the failure is informational.

**This becomes a real blocker for a Portugal launch specifically.** Multibanco is a mainstream way Portuguese customers pay for larger purchases, and a four-figure wedding booking is precisely the amount people reach for it. Enabling it without this fix means telling paying clients, twice, that they haven't paid — on the highest-value bookings in the product.

### 3. The stuck-gig sweep would false-alarm on a legitimately clearing payment (theoretical)

`find_and_flag_stuck_gigs` notifies admins about non-terminal gigs older than `STUCK_BOOKING_MAX_AGE_HOURS`, default **720 hours (30 days)** — far longer than any delayed method takes, so this will not fire in practice. Noted for completeness rather than as a risk. The sweep is also observational by design: it logs and notifies, never transitions a gig, so it cannot corrupt state either way.

### Scope note: MVP is one payment per booking

Recorded here because it bounds the fix above. A booking takes a single payment; there is no splitting a booking across multiple cards or methods. The multi-payment schema from B-1 stays exactly as it is — `StripePaymentKind` of `base` / `difference` / `extras` are sequential charges against one gig, not parallel tenders for one charge — and no third dimension is being added on top of it.

## The new list endpoints are unit-tested but have never run against a populated queue

`GET /v1/booking-requests`, `GET /v1/gigs` and `GET /v1/client/bookings` pass 11 tests (`api/tests/test_list_endpoints_v1.py`) covering scoping, filters, cursor behaviour under tied timestamps, and malformed cursors. Against the live local backend they have only ever been called by a user with no data, returning `{"items": [], "next_cursor": null}` — correct, but the empty case. `scripts/seed_dev.py` does not create booking requests, so no seeded fixture exercises them either.

**Practical consequence for F-6:** the pro app's Requests, Gigs and Today tabs are the first real consumers. If a response looks wrong there — a missing field, an unexpected null, a filter that doesn't narrow, a cursor that doesn't advance — treat the backend as a live suspect rather than assuming the Flutter side is at fault. In particular `seconds_until_expiry` and the `ClientBookingListItem` gig/payment roll-up have never been observed with real rows behind them, and the gig roll-up depends on `meta["booking_request_id"]` being present, which only holds for gigs created through the accept-booking path.
