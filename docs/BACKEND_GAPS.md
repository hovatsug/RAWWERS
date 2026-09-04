# Backend gaps

Confirmed backend behavior that the Flutter rebuild (F-0–F-8) needs to design around or route around, rather than something to silently paper over client-side. Entries here are verified against the running API or its source, not assumed. Append as F-6/F-7 discovery turns up more (the original task brief calls for several: canonical chat route family, review-gates-download, `GET /v1/client/bookings` — none of those are independently confirmed yet, so they're not listed below until they are).

## `complete_photo_upload` is not idempotent

`POST /v1/media/photos/{media_asset_id}/complete` only succeeds while the asset's status is still `uploading` or `created`; it transitions to `processing` on success and rejects a second call with a 409 `invalid_state` (`api/app/api/v1/media.py`, `complete_photo_upload`).

**Why this matters on mobile specifically:** the classic bad-signal failure mode — the request reaches the server, the server processes it and returns 200, but the client never receives the response (connection drops, app backgrounds, timeout fires first) — leaves the client believing the call failed. If the app auto-retries in that state, the retry 409s even though the upload actually succeeded. Confirmed in F-3: `PhotoUploadService` deliberately calls `complete` at most once and never auto-retries it, surfacing the failure to the caller instead. A real fix (an idempotency key, or accepting a repeat call in the already-`processing`/already-`ready` state as a no-op success) would need to happen server-side; not in scope for the Flutter rebuild.

## ~~Portfolio photos are uploaded `owner_only`, so nobody but the pro can fetch them~~ — FIXED

`POST /v1/media/photos/uploads` hardcodes `visibility=MediaVisibility.owner_only` (`api/app/api/v1/media.py`, `create_photo_upload`) and its request schema has no `visibility` field at all. The video path right next to it does the opposite: `create_mux_upload` accepts `visibility` and defaults `portfolio_reel` to `public`. So an uploaded portfolio **photo** is unreachable through `GET /v1/media/{id}` for anyone but its owner — `_ensure_read_access` 403s — while an uploaded portfolio **video** is public.

The dev seed already writes `visibility=public` for portfolio photos, which confirms `public` is the intent and the upload endpoint is the outlier rather than the policy.

**Not currently a blocker,** because discover and profile now resolve image URLs server-side (see below) and never consult per-asset visibility. It becomes one the moment anything needs `GET /v1/media/{id}` for a portfolio photo — a full-portfolio screen, a share sheet, the web app — where it will present as an authentication bug rather than a visibility bug.

**Fixed:** `PhotoUploadCreateRequest` now accepts `visibility`, and `_default_visibility` gives `portfolio_reel` the same `public` default the video path already used. Migration `20260904_0043` backfills existing rows, narrowed to portfolio photos still sitting at the old hardcoded default so a deliberate choice is never overwritten.

## ~~Booking requests expire after 24 hours, not the 48 the product describes~~ — RESOLVED (copy corrected; literal noted)

`client_booking_request` sets `expires_at=datetime.now(timezone.utc) + timedelta(hours=24)` (`api/app/api/v1/client_launch.py:407`). It is a literal, not a setting — there is no `BOOKING_REQUEST_EXPIRY_HOURS` to change. Confirmed live: a request created at 11:26 came back with `expires_at` at 11:26 the next day.

Everything downstream inherits it correctly — `seconds_until_expiry`, the pro app's countdown, the expiry sweep — so nothing is inconsistent internally. What was wrong is the **copy**: both apps told people 48 hours. That was corrected to 24 in F-7 (`requests_screen.dart`, `bookings_screen.dart`). The copy follows the code because the failure modes are not symmetric: a pro told they have 48 hours who replies at hour 30 has already lost the request.

**Resolved: 24 is the truth, and the copy follows it.** Confirmed as the intended behaviour rather than changed. Both apps now say 24 hours, and so does the booking request form before the request goes out.

**One thing left, agreed and deferred:** the window is a bare literal at `client_launch.py:407`, not a setting. Every other tunable of its kind in this codebase lives in `app/core/config.py` behind an env alias — `BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS` is right there, so the sweep that enforces the deadline is configurable while the deadline itself is not. `BOOKING_REQUEST_EXPIRY_HOURS` should exist. Not done now because changing it is only worth doing at the moment someone actually wants a different window, and doing it then keeps the change and its reason together.

## ~~The client's message list has no name to put on a conversation~~ — FIXED (partly)

`ChatThreadSummary` carries `pro_user_id`, `client_user_id`, `session_id`, `status`, `created_at`, `updated_at` — and no display name or avatar for either side. `ChatThreadDetailResponse` adds `messages` and a free-form `lead_profile` dict, still with no pro name. Confirmed live: `GET /v1/chat/threads` returns two threads identified only by UUID.

So the client's Messages tab titles every conversation "Photographer". A UUID would be worse, but neither is a name, and a list of identical rows is not a usable inbox once someone has talked to three photographers.

There is also no last-message preview or unread count, so the rows carry no signal about which conversation needs attention.

**Fixed for the pro's name.** `ChatThreadSummary` now carries `pro_display_name` and `client_display_name`, resolved in one batched lookup across the page and applied to all five construction sites (create, client list, pro list, detail). A pro is named by `ProProfile.display_name` — the brand a client recognises — falling back to the account name.

**And registration now collects a name**, which is what makes `client_display_name` populate — see below. Verified live: a thread created by a newly registered client comes back with both sides named.

**Still open — deliberately deferred, not overlooked:**

1. **No last-message preview or unread count.** The rows carry no signal about *which* conversation needs attention. Names make the list readable; they do not make it scannable. A preview means joining the latest `ChatMessage` per thread (a lateral join, or a denormalised `last_message_at` / `last_message_preview` on `ChatThread`); an unread count needs a per-participant read cursor, which does not exist in the schema at all. Deferred on purpose: a readable thread list beats an unreadable one, and scannable comes after the booking loop closes.

2. **No `pro_cover_url` on the summary.** An avatar per row would help scanning too; `resolve_image_urls` already exists to do it. Same deferral.

## ~~A client cannot build a booking request from the profile response alone~~ — FIXED

`POST /v1/client/bookings/request` requires `niche_slug` and validates it against the chosen package: `if not niche or niche.slug != body.niche_slug: raise ... "niche_slug does not match package"` (`api/app/api/v1/client_launch.py:390`). But `ClientProfilePackage` — the only package representation the client profile endpoint returns — carries no niche at all: `id`, `title`, `description`, `duration_minutes`, `price`, `currency`, `included_photos`, `extra_photo_price`, `proofs_sla_days`, `finals_sla_days`.

So a client holding a profile response cannot name the niche the package belongs to. The workaround is two more requests — `GET /v1/pro/{pro_user_id}/packages` returns `ProPackageView` with `niche_id`, and `GET /v1/niches` maps id to slug — which makes the client do a join the server already has in hand, on the highest-intent action in the product.

**Fixed:** `ClientProfilePackage` now carries `niche_slug`, joined from `Niche` in the packages query rather than looked up per row. Verified end to end against the live backend: the slug the profile hands over is accepted by `POST /v1/client/bookings/request`, and the booking appears in `GET /v1/client/bookings`.

The redundancy itself remains — the client still echoes back a value the server could derive from `package_id` alone — but it is now a value the client actually has.

## ~~Blocked-off time did not block bookings on the path the apps use~~ — FIXED in P-2

Recorded as "the blackout route writes to a table nothing enforces". That
was close, but the shape was worse. Two tables hold the same fact -
`ProBlackoutDate` (written by `POST /v1/pro/me/availability/blackouts`)
and `ProAvailabilityException` (written by
`PUT /v1/pro/scheduling/exceptions`) - and enforcement read one, the
other, or neither depending on the path:

| path | blackouts | exceptions |
| --- | --- | --- |
| `POST /v1/client/bookings/request` — what both apps call | no | no |
| `POST /v1/booking-requests/{id}/accept` — **creates the gig, writes the dates** | no | no |
| `POST /v1/pro/bookings/{id}/confirm-slot` | no | yes |
| request creation in `pro_onboarding.py` / `chats.py` | yes | no |

So the honeymoon case was live on the whole client funnel, and blocking
time through the *successor* route did not help either: accept never
checked anything. Fixed by routing every decision through
`app/services/availability_blocks.py`, which reads both tables. The
blackout query also used `scalar_one_or_none()`, so two overlapping
blocks raised instead of refusing.

Enforcement is "the window is entirely blocked", not "overlaps at all":
a booking request carries a window the client is flexible within, and
refusing a fortnight that clips one blocked afternoon would push clients
toward narrow windows. The exact time is pinned at confirm-slot, which
checks the precise slot.

## ~~Two endpoints write weekly availability, and one silently resets timezone and location mode~~ — DEPRECATED in P-2

`POST /v1/pro/me/availability/rules` and
`POST /v1/pro/me/availability/blackouts` are now marked `deprecated` in
OpenAPI **and** signal it at runtime: `Deprecation: true`, a `Link`
header naming the successor, a `Warning` header, and a
`deprecation_notice` in the response body. A route marked deprecated only
in the docs is a route somebody keeps calling.

Deprecated rather than repointed. Repointing the blackout route at
`ProAvailabilityException` would silently change what existing callers'
writes mean, and leave the AI chat snapshot (`chat_concierge.py`) reading
an empty table — two new failure modes to fix one. Both routes still
work, and their writes now genuinely block bookings, so nothing a
photographer has already recorded stops counting.

No `Sunset` header: that is a promise about a removal date, and one has
not been decided. Add it here when it is.

## ~~Two backend schemas share the name `AvailabilityRuleView`, and the generated client silently kept the wrong one~~ — FIXED in P-3

`app/schemas/onboarding.py` and `app/schemas/scheduling.py` both define a
class called `AvailabilityRuleView`, with different fields. FastAPI copes
by qualifying the keys (`app__schemas__scheduling__AvailabilityRuleView`)
but leaves both `title`s identical - and `swagger_to_dart` names the Dart
class from the title. So both collapsed into one `AvailabilityRuleView`,
the onboarding shape won, and `AvailabilityRulesResponse.items` was typed
with fields the scheduling endpoint does not return.

Reading `GET /v1/pro/scheduling/availability-rules` threw
`type 'Null' is not a subtype of type 'num'` at runtime. Nothing static
caught it: the class existed, the names were plausible, `flutter analyze`
was clean, and the contract check passed because the generated client
matched the schema it was given.

Fixed client-side in `tool/filter_openapi.dart`, which now renames
qualified schemas apart (`SchedulingAvailabilityRuleView`), rewrites their
titles and `$ref`s, and **fails the build** if any two schemas that reach
the generator still share a title. `test/api/schema_collisions_test.dart`
decodes the real payload of each endpoint.

**Root cause removed:** `onboarding.AvailabilityRuleView` is now
`PublicAvailabilityRuleView`, which is also the more accurate name - it is
the shape the public profile endpoint returns. One duplicated name across
503 schema classes, so nothing else was affected. The filter's rename
heuristic no longer fires; the duplicate-title guard stays, because the
next collision will not necessarily be one FastAPI flags.

## Gear registration is tagged `repairs`, which is a taxonomy mistake

`POST/GET/PUT/DELETE /v1/pro/me/gear-items` live in `api/app/api/v1/repairs.py`
and carry the `repairs` tag, because the repairs marketplace consumes
them. But to a photographer these are profile data - the bodies and lenses
they own, with serial numbers - and they are needed long before anyone
books a repair. Anyone reading the API by tag will look for gear under
profile or onboarding and not find it.

Not re-tagged: the tag is part of every generated client method name, so
moving it would churn the whole surface for a naming concern. The Flutter
client rescues these four operations by path allowlist in
`app/tool/filter_openapi.dart` (`_includedPathPrefixes`), which is where
to look when wondering why `repairs_client.dart` exists in an app with no
repairs feature.

## LAUNCH BLOCKER for one niche: working hours cannot cross midnight

`PUT /v1/pro/scheduling/availability-rules` rejects any rule whose
`end_local` is not after `start_local`:

```
422 {"code": "validation_error", "message": "start_local must be before end_local"}
```

So a photographer who works 20:00 to 02:00 cannot describe their hours at
all. `events_nightlife` ("Events & Nightlife") is a seeded niche with its
own power decay curve tuned for long shoots, so the product ships a
category whose practitioners cannot enter realistic availability.

If such a rule did exist in the database, both availability checks would
then refuse every slot, including squarely mid-shift, because both compare
plain times without handling a wrap:

| slot against a 20:00-02:00 rule | `validate_slot_available` | `_validate_availability` |
| --- | --- | --- |
| 21:00-22:00 (mid-shift) | refuses | refuses |
| 00:30-01:30 (after midnight) | refuses | refuses |
| 20:00-21:00 (start of shift) | refuses | refuses |

`_is_in_quiet_hours` in `notifications.py` handles exactly this shape
correctly (`if start < end: ... else: now >= start or now < end`), so the
pattern is already established in the codebase - it just was not applied
here.

Not fixed: how overnight availability should be modelled is a product
decision, not a transcription of the quiet-hours branch. Either a rule may
wrap (and both checks learn the two-branch comparison, and the slot
generator learns to emit slots past midnight), or the UI splits overnight
hours into two rules (20:00-23:59 plus 00:00-02:00) and the backend keeps
its simple invariant. The second is less code and more explaining; the
first is invisible to the pro. The Flutter availability screen currently
mirrors the backend's rule, so it refuses the same input rather than
sending something that 422s.

## The scheduling test fixture failed after 18:00 UTC — FIXED in P-3

Not a product gap, but it broke the regression-comparison method these
commits rely on. `_seed_pro_and_booking` built a weekly availability rule
from the current clock - start hour to start + 6h - so after 18:00 UTC the
rule wrapped past midnight (21:00 to 03:00). `validate_slot_available`
compares plain times, so every confirm-slot test failed all evening and
passed again by morning. The fixture now seeds a full day: those tests are
about conflicts and notice periods, not office hours.

This mattered beyond the fixture. Every commit in this rebuild is verified
by comparing the failure set at HEAD against the same subset with changes,
so a baseline taken before 18:00 UTC and a comparison taken after it would
have shown two phantom regressions - the verification method itself was
unreliable for half the day, in a way that looked exactly like a real
regression.

**Swept the rest of the suite for the same shape.** Three other fixtures
derive times from the clock; all three are safe, for reasons worth
recording so nobody re-checks them:

- `test_ai_concierge_v1.py:71` calls `.time().replace(hour=8, minute=0,
  second=0, microsecond=0)`, which overrides every component - the clock
  contributes nothing.
- `test_client_launch.py:153` uses fixed dates.
- `test_notifications_v1.py:85` builds a quiet-hours window of now +/- 1
  hour, which *does* wrap past midnight between 23:00 and 01:00 local -
  but `_is_in_quiet_hours` handles wrapped windows correctly, so it holds
  at every hour.

That last one is what turned up the midnight-crossing gap recorded above:
the notification path handles a wrapped window and the scheduling path
does not.

## ~~`GET /v1/niches` returned no id, so a niche picker could not call anything keyed on one~~ — FIXED in P-5

The pro-side pricing preview added in P-2 is
`GET /v1/pro/me/pricing/niches/{niche_id}`, but the only list of niches
available to a client returned `{slug, name}`. An existing package carries
its `niche_id`, so editing one worked; a pro pricing a *new* niche picked a
slug and had no id to preview with - which is exactly the case the endpoint
was added for.

`id` is now included. One additive field, and it removes the same trap for
every future picker rather than adding a slug-shaped variant of one route.

## `/v1/niches` is still `list[dict[str, str]]` with no response schema

Related to the above and unchanged: this endpoint has no Pydantic response
model, so the shape is convention rather than contract, and the Flutter
client reads it defensively (dropping rows missing a key rather than
throwing). Adding `id` was safe because a uuid serialises as a string, but
the next field that is not a string will not be. Third instance of the
unenforced-shape pattern recorded in this document.

## No video poster frames in the portfolio preview

`ClientProProfileResponse.portfolio_preview` resolves a signed thumbnail for photos, but portfolio **videos** are served through Mux and have no `MediaObject` rows behind them, so `thumbnail_url` is always null for `kind == "video"`. The pieces to fix it exist — `asset.meta["playback_id"]` and `create_mux_playback_token` — but Mux's image service (`image.mux.com/{playback_id}/thumbnail.jpg`) needs its own signed token, separate from the playback token, so it isn't a one-liner.

Low urgency: `portfolio_video_count` is 0 for every seeded pro and video upload is behind the `video_uploads_enabled` flag. It becomes visible the first time a pro uploads a reel.

## Unenforced schema shapes: `ClientPreferenceView.location` and `top_niches`

Two payload shapes the client app depends on are conventions rather than contracts. Both are read defensively in Flutter, which is the right call for now, but neither is protected against a writer that disagrees.

1. **`ClientPreferenceView.location` is `dict`** (`api/app/schemas/client_launch.py`) — untyped, `additionalProperties: true` in the OpenAPI schema. The whole client app is gated on a browse location, which is read out of this object as `{"country": ..., "city": ...}`. That key convention exists only in the seed data and in the two places that write it. Anything that writes a different shape — an admin tool, a migration, a future preferences screen — silently returns the client app to the "where are you looking?" prompt with no error anywhere. `BrowseLocation.fromPreferenceLocation` treats a shape it doesn't recognise as "not set", so the failure is at least benign, but it's invisible.

2. **`ClientDiscoverCard.top_niches` is `list[dict]`** — generates as `List<Map<String, dynamic>>`, so every key access is untyped. The rows carry `slug`, `tier`, `score`, `verified`, `capability`, `confidence`; the card reads `slug` and skips any entry where it isn't a non-empty string.

3. **`ClientBookingStatusResponse.timeline` is `list[dict]`** — same shape problem, found while building the booking detail screen. The backend writes `at`, `from`, `to`, `reason`; the app parses defensively and drops rows missing a usable `at` or `to` rather than rendering "null → null".

**Fix:** give both a real Pydantic model (`ClientLocation`, `ProNicheSummary`). That is a breaking schema change for any existing writer of a differently-shaped `location`, so it wants a migration audit first, not a drive-by edit.

## LAUNCH BLOCKER: no email is ever delivered, and push does not exist

> **Status.** The outbox drain is FIXED (`b91ee8ba`) and in-app notifications now work end to end — verified live in F-7 discovery: a real booking request produced `booking.request_received` in the pro's `GET /v1/me/notifications`. What remains is items 1 and 4 below: **no mail provider**, and **no push channel at all**. Both are launch blockers rather than task blockers — the apps are built to work without them, and the chain is testable end to end via in-app alone.

Found in F-5 by running the real app against the local backend: `POST /v1/auth/verify-email/request` returns **204 and nothing arrives**. The endpoint is not broken — it does exactly what it should, and then the mail dies in two separate places downstream. Both are verified in source, not inferred.

**1. No mail provider is configured.** `get_mail_provider()` (`api/app/services/mail.py:58`) unconditionally returns `ConsoleMailProvider()` — there is no settings switch, env var, or branch that selects a real transport. Every send in the system (`send_verification_email`, `send_password_reset_email`, `send_template_email`) therefore writes to the log and returns success. Nothing distinguishes "sent" from "printed".

**2. Nothing drains the outbox periodically.** `_create_email_verification` (`auth_service.py:92`) correctly enqueues an `email.verify.send` outbox event, and `dispatch_outbox_events` (`api/app/tasks/outbox_tasks.py`) correctly dispatches it to the mail provider. But that task is **not in `celery_app.conf.beat_schedule`** — the only callers are the Stripe and Mux webhook handlers (`api/app/api/v1/webhooks.py`, `.delay()`), plus tests. `docker-compose.yml` also runs a `worker` service but no `beat` service, so even the sweeps that *are* scheduled (booking-request expiry, payout-hold release, dispute escalation, stuck bookings) never fire locally. So an auth email sits pending until an unrelated payment webhook happens to kick the queue.

**3. This is not only email — in-app notifications go through the same undrained outbox.** `enqueue_notification` (`api/app/services/notifications.py:245`) does *not* write a notification row synchronously; it enqueues a `notify.create_inapp` outbox event. So `GET /v1/me/notifications` returns an empty list for the same reason, and the in-app bell is as silent as the mailbox. Anything built on top of the notification feed inherits this.

**4. Push notifications do not exist.** Not unconfigured — unbuilt. There is no FCM, APNs, or device-token storage anywhere in `api/`, and `FollowupChannel` is `in_app | email | sms | phone_call`; push is not modelled at all. This matters more than the missing mail provider for the 48h window specifically: in-app notifications only reach someone who has already opened the app, so they cannot *tell* a photographer a request arrived. Email and push are the only channels that reach outward, and neither delivers today.

**Why this blocks the end-to-end run rather than just verification UX:** booking requests auto-decline after 48h. A photographer who never learns a request arrived cannot act inside that window, so the single most time-critical path in the product depends on notification channels that currently deliver nothing — neither email nor in-app. This is not an F-5/F-6 blocker for the auth work — email verification gates no API, and the apps are built to work without it — but the product cannot be exercised end to end until a provider is configured *and* the outbox is drained on a schedule (`dispatch_outbox_events` added to `beat_schedule`, plus a `beat` service in compose). All three fixes are server-side and outside the Flutter rebuild's scope.

## ~~No list endpoints exist for booking requests, gigs, or bookings~~ — FIXED in `b91ee8ba`

**Resolved.** `GET /v1/booking-requests`, `GET /v1/gigs` and `GET /v1/client/bookings` were added, with keyset cursor pagination. Kept here because the original finding explains why those routes look the way they do, and because the two entries below qualify the fix. Original finding follows.

Verified against the **full** (unfiltered) OpenAPI schema in F-6 discovery, so this is not an artifact of the MVP tag filter. The API exposes only fetch-by-id and actions:

- Booking requests: `GET /v1/booking-requests/{request_id}` — no `GET /v1/pro/booking-requests`, no collection route of any kind.
- Gigs: `GET /v1/gigs/{gig_id}` — no `GET /v1/pro/gigs`.
- Client bookings: `GET /v1/client/bookings/{booking_id}` — no list. Independently corroborated: `web/lib/api/booking.ts:28-33` already carries a "BACKEND GAP, reported not fixed" comment saying the same thing, and its `clientBookings()` wrapper calls a route that does not exist and always fails.

Payouts and earnings are the exception and *do* have collection routes (`GET /v1/pro/payouts`, `GET /v1/pro/earnings/ledger`), so this is a specific omission rather than a general API style.

**What it blocks:** any screen whose job is "here is your queue of work" — the pro app's Requests, Gigs, and Today tabs, and the client app's bookings list. A pro cannot enumerate the requests awaiting them, which is the same 48h-window problem from the notification gap arriving by a second independent route. There is no client-side workaround: an id-only API cannot be turned into a list, and the notification feed that might have supplied the ids is itself empty (see above). Adding the list routes is a server-side task.

## Chat: `/v1/chats/*` is deprecated in favour of `/v1/chat/threads/*`

Two API surfaces existed over the **same** `ChatThread`/`ChatMessage` tables — not two systems, two front doors. F-7 picked `/v1/chat/threads/*` + `/v1/pro/chat/threads/*` (`app/api/v1/ai_concierge.py`) as canonical. `/v1/chats/*` + `/v1/pros/{id}/chats` (`app/api/v1/chats.py`) is **deprecated, not deleted** — it stays routable.

Why B won: it holds every list endpoint (`GET /v1/pro/chat/threads`, and `GET /v1/chat/threads` added in `8d6b89b4`), supports guest chat via `session_id`, is feature-flagged and rate-limited, and drives AI replies through the outbox. It is also the only family with a consumer — the web app calls `/pro/chat/threads/*` and never touches `/v1/chats/*`. A's `takeover`/`create-booking-request` routes suggested it was the live one, but nothing calls them.

Three capabilities live only in A. These are gaps to close on B, not features consciously dropped:

### 1. No `ChatHandoff` audit row when a pro takes over

A writes a `ChatHandoff` row (`chats.py:174`, `chats.py:309`) recording that a human took the conversation and why. B changes thread status and records nothing. That row matters twice over: in a dispute it is the evidence of when a human became responsible for what was said, and in tuning the concierge it is the only signal for how often and why the AI is being rescued. The `ChatHandoff` model already exists and is unused by B.

### 2. No automatic handoff when the AI hits its limits — the sharp one

A escalates on its own via `_handoff_due_to_limit` for three conditions: `ai_calls_disabled`, `message_limit_exceeded`, `token_limit_exceeded` (`chats.py:255-269`). B has no equivalent. So on B a client can keep talking to a concierge that has hit its ceiling and simply stopped replying, with nothing telling the pro to step in and nothing telling the client why the answers stopped. Silence is the worst possible failure here: the client reads it as being ignored by the photographer, not by a bot that ran out of budget.

### 3. `pro_takeover` vs `pro_active` — one concept, two enum values (needs reconciling, not documenting)

`ChatThreadStatus` carries both. A sets `pro_takeover`, B sets `pro_active`, for the same event: a human took over. Every reader must handle both, forever, or silently mishandle threads created through the other door.

**Scope of the fix — a small standalone backend task, deliberately not done inside F-7:**

- **Writers are few and known.** `pro_takeover` is written at exactly two sites, both in the deprecated `chats.py` (`:173`, `:308`). `pro_active` at two sites in `ai_concierge.py` (`:172`, `:284`). Nothing else in `api/` assigns either.
- **No reader branches on the values** beyond those writes — checked across `api/` and `web/`; the web app never compares against either.
- **The migration is a plain `UPDATE`, not an enum alter.** The column is `Enum(..., native_enum=False)`, stored as `character varying`, so there is no Postgres enum type to modify: `UPDATE chat_thread SET status='pro_active' WHERE status='pro_takeover'`.
- **Keep `pro_active`** (B's value, the canonical family) and drop `pro_takeover` from the enum once no rows hold it.
- **Watch for**: `ChatThreadStatus` is serialized into the OpenAPI schema, so removing a value changes the generated client — regenerate, and check nothing in the Flutter app pattern-matches exhaustively on it.

Estimated as one migration, two line changes in the deprecated file, one enum edit, and a client regeneration. The reason to do it separately is that it touches a shipping enum, not that it is large.

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
