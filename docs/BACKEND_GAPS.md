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

## No list endpoints exist for booking requests, gigs, or bookings

Verified against the **full** (unfiltered) OpenAPI schema in F-6 discovery, so this is not an artifact of the MVP tag filter. The API exposes only fetch-by-id and actions:

- Booking requests: `GET /v1/booking-requests/{request_id}` — no `GET /v1/pro/booking-requests`, no collection route of any kind.
- Gigs: `GET /v1/gigs/{gig_id}` — no `GET /v1/pro/gigs`.
- Client bookings: `GET /v1/client/bookings/{booking_id}` — no list. Independently corroborated: `web/lib/api/booking.ts:28-33` already carries a "BACKEND GAP, reported not fixed" comment saying the same thing, and its `clientBookings()` wrapper calls a route that does not exist and always fails.

Payouts and earnings are the exception and *do* have collection routes (`GET /v1/pro/payouts`, `GET /v1/pro/earnings/ledger`), so this is a specific omission rather than a general API style.

**What it blocks:** any screen whose job is "here is your queue of work" — the pro app's Requests, Gigs, and Today tabs, and the client app's bookings list. A pro cannot enumerate the requests awaiting them, which is the same 48h-window problem from the notification gap arriving by a second independent route. There is no client-side workaround: an id-only API cannot be turned into a list, and the notification feed that might have supplied the ids is itself empty (see above). Adding the list routes is a server-side task.
