# Backend gaps

Confirmed backend behavior that the Flutter rebuild (F-0–F-8) needs to design around or route around, rather than something to silently paper over client-side. Entries here are verified against the running API or its source, not assumed. Append as F-6/F-7 discovery turns up more (the original task brief calls for several: canonical chat route family, review-gates-download, `GET /v1/client/bookings` — none of those are independently confirmed yet, so they're not listed below until they are).

Every deploy step recorded below is also listed, in order, in [DEPLOY_CHECKLIST.md](DEPLOY_CHECKLIST.md). An entry that adds a deploy step adds it there too.

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

## ~~Working hours cannot cross midnight~~ — FIXED

A rule whose `end_local` is not after its `start_local` now means it ends
the next day, with `weekday` anchoring the start: Friday 20:00-02:00 is
Friday night into Saturday morning and belongs to Friday.

The comparison lived in three places and each assumed a rule began and
ended on the same day. All three now go through
`app/services/availability_rules.py`, which anchors a rule to its start
date and follows it past midnight - the save validation, the slot check,
the booking-request check, and the slot generator.

Wrapping rules are capped at 16 hours. Without a bound, `20:00-19:00` - a
plausible typo - reads as 23 hours of availability rather than a mistake.
All-day availability is a non-wrapping `00:00-23:59` and is unaffected.

The deprecated `POST /v1/pro/me/availability/rules` still rejects wrapping
rules. Teaching a retiring route a new trick is the wrong direction; its
deprecation notice carries the reason.

Fixing this also corrected a latent leniency: the old checks compared bare
times, so a slot running from 23:30 to 00:30 passed against a same-day
rule because `00:30 <= 23:59` reads as true. It now correctly refuses,
unless a wrapping rule genuinely covers it.

## DST: a shift crossing spring-forward books an hour that does not exist

Pre-existing and not fixed here, but crossing midnight makes it far more
reachable, so the mechanism is worth writing down rather than rediscovering.

Every conversion in the scheduling path builds local times with
`datetime.combine(d, t).replace(tzinfo=ZoneInfo(...))`. `replace` attaches
a zone without asking which side of a transition the time falls on, so on
a spring-forward night it silently takes the pre-transition offset.

Concretely, a Europe/Lisbon rule of 22:00-04:00 across 28 March 2027,
when clocks jump 01:00 to 02:00:

```
local start : 2027-03-27 22:00:00+00:00   utc 22:00
local end   : 2027-03-28 04:00:00+01:00   utc 03:00
wall-clock span: 6:00:00      real elapsed: 5:00:00
```

Two consequences:

1. `generate_candidate_slots` steps in wall-clock increments from the local
   start, so it emits a slot at 01:30 local - a time that does not occur
   that night. `replace(tzinfo=tz)` resolves it to 01:30+00:00, which is
   02:30 local after the jump. A client books "01:30" and is booked at
   02:30.
2. The shift is an hour shorter than the rule claims, so the last slot of
   the night falls outside the real window. Autumn's fall-back is the
   mirror image: an ambiguous 01:30 resolves to one of two real instants
   with no rule about which.

The fix is to stop using `replace` for local wall-clock times, resolving
through a fold-aware conversion instead and deciding explicitly what a
non-existent or ambiguous local time means for a booking. That is a
correctness change across the scheduling module, deliberately not folded
into the midnight-crossing work. Twice a year, for anyone shooting nights.

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

## Found by the first end-to-end run

Four defects, all on the path a real photographer takes. None were
reachable from unit tests, because each needed the previous step to have
actually happened.

### ~~`POST /v1/admin/pros/{id}/kyc` raised NameError on every call~~ — FIXED

`KYCStatus` was never imported in `admin.py`, so the branch that awards a
referral reward on first approval raised `NameError` and the endpoint
returned a 500 — every time. This is the only gate between a photographer
and going live, and it had never worked.

### ~~`PUT /v1/pro/me/niches` 500s when the primary niche is also in the list~~ — FIXED

Sessions are `autoflush=False`, so a `ProNiche` added in the first loop was
invisible to the `SELECT` in the primary-niche block, which then inserted a
second row for the same niche and violated `uq_pro_niche_pro_niche`. It
fires whenever `primary_niche_slug` names a niche that is also in `niches`
— the ordinary way to call it. Fixed with a `db.flush()`.

### ~~`GET /v1/pro/me/portfolio` counted photos differently from onboarding~~ — FIXED

`complete_photo_upload` sets `processing` and hands off to a worker;
`onboarding_checks` counts only `ready`. The portfolio endpoint counted
every asset, so a photographer saw "12 of 12" on the portfolio screen while
the onboarding step still read incomplete. Now counts `ready` only, and
each item carries its `status` so the grid can say "Processing" instead of
showing a blank tile that reads as a failed upload.

### ~~The listing preview said "live" to a pro nobody could find~~ — FIXED

Going live takes **two** admin approvals, not one: KYC, and then publishing
the listing (`POST /v1/admin/onboarding/pros/{id}/approve`, which sets
onboarding status to `approved_public`). Discover joins `ProOnboarding` and
requires that status. The preview checked KYC, accepting-bookings,
completeness and pricing — but not the publish gate — so an activated but
unpublished photographer was told "clients can find you". Now reported as
`not_published_yet`.

## A Stripe event marked delivered without its effect landing — NOT REPRODUCED, now instrumented

Observed once during the first end-to-end run: `payment_intent.succeeded`
was signature-verified, accepted (200), and its outbox row ended
`delivered` with `attempts=0`, yet the `StripePayment` row stayed
`pending`. Replaying the same stored payload applied it correctly.

**Five deliberate reproduction attempts, each a fresh booking, a fresh
PaymentIntent, a real card confirmation and a signed webhook: applied
correctly every time.** Not reproduced, and still not explained.

Two things were fixed while trying, both real:

1. `dispatch_outbox_events_task` ran `escalate_due_disputes` and
   `process_due_scheduled_notifications` *inside the same transaction* as
   outbox delivery, before the only `db.commit()`. An exception in either
   sweep skipped the commit, and the `finally` closed the session -
   silently discarding every delivery in the batch, marks and effects
   alike, with nothing logged. Outbox delivery now commits first; the
   sweeps run after, each in its own transaction, and their failures are
   logged instead of swallowed.
2. The per-row `except Exception:` swallowed the exception entirely, so a
   handler that raised left a row marked failed with no record of why.

Instrumentation added so the next occurrence explains itself:
`outbox_event_applied` / `outbox_event_failed` per row with the event id
and attempt count, and on the money path `stripe_succeeded_applying` with
the payment and gig status *before* the change, plus a named warning on
every early return (`stripe_succeeded_no_payment_row`,
`stripe_succeeded_no_gig`, `stripe_succeeded_matched_store_order`, …).
Verified firing, in order, by dispatching in-process.

**The instrumentation was initially unreadable, for a worse reason than
buffering.** Celery configures only its own loggers and otherwise takes
over logging setup entirely, so `app.*` loggers had no handler in a worker
process: everything the application logged from inside a task was
discarded. Celery's own task lines still appeared, so logging looked like
it worked. Since the outbox is drained *only* in the worker, none of this
instrumentation would have been visible when it mattered.

Fixed by connecting `configure_logging` to Celery's `setup_logging`
signal, which also stops Celery clobbering it. `PYTHONUNBUFFERED=1` is set
on `worker` and `beat` as well. Verified by dispatching to the worker and
reading structured JSON back out of `docker logs`.

(The earlier note here said the worker produced no stdout at all. That was
an artifact of `docker compose logs --since` against a recreated
container; `docker logs <id>` showed output the whole time.)

## `GigStatus.final_delivered` is never set

The enum value exists and is read in three places (reviews, disputes,
prints) but nothing ever assigns it. Gigs go `paid -> completed` directly,
by a system transition when the selection is submitted and payment has
settled. Not a hole in the loop - the photographer is credited either way -
but any logic keyed on `final_delivered` is dead.

## Stripe Connect: verified against real Stripe, with two blockers found

Connect is now enabled in test mode (Express). What follows is what was
actually run, not what was inferred.

**Proven, against real Stripe:**

- All three request shapes are accepted: `Account.create` (Express, PT,
  `capabilities.transfers.requested`, `business_type=individual`),
  `AccountLink.create` (`type=account_onboarding`) and
  `Account.retrieve`. Driven through our own endpoints, not curl.
- `account.updated` **does** fire for connected accounts and reaches us.
  The Stripe CLI labels it `connect account.updated` - it arrives on the
  connected-account channel, carrying a top-level `account` field, and
  the platform channel is not involved.
- The event is ingested, dispatched through the outbox, applied by the
  worker, and **the `payout_account` row moves**. Watched moving
  `disabled` -> `pending_verification` on a real event, with the
  matching `admin_audit_log` row.
- Account creation is idempotent against real Stripe.

**BLOCKER 1: the onboarding link cannot be created at all.**
`CONNECT_RETURN_URL`/`CONNECT_REFRESH_URL` defaulted to
`rawwerspro://payouts/return`. Stripe rejects a custom scheme outright:
`url_invalid`, *"Not a valid URL"*, on `return_url`. Our endpoint
returned 502 and no photographer could ever have started onboarding.
Both must be `http(s)`. Set locally to `https://rawwers.com/payouts/...`
so the flow could be exercised; **the real destination is still a design
decision** - see "Where Connect onboarding should return to" below.

**BLOCKER 2: nothing can receive the return anyway.** There is no
`CFBundleURLTypes` in `app/ios/Runner/Info.plist` and no `intent-filter`
with a scheme in `AndroidManifest.xml`, so `rawwerspro://` is not
registered on either platform. The app also cannot *open* the hosted
link - the payouts screen takes an `openUrl` callback and falls back to
the clipboard, because `url_launcher` is still not a dependency.

**Still not proven:** that completing hosted onboarding moves the account
to `active`. That transition needs a human to finish Stripe's form in a
browser; everything downstream of it - the event arriving, being applied,
and the row moving - is proven above with a real event.

### Where Connect onboarding should return to - open decision

Stripe requires http(s), so the return has to land on the web first. Two
options:

1. **A plain page on `rawwers.com`** saying "you can go back to the app
   now". No new dependencies. The payouts screen already re-reads live
   status from Stripe on open and reconciles, so returning by hand
   self-heals. Honest, slightly clumsy.
2. **Universal links / app links** on the same URL, so the app reopens
   itself. Needs `apple-app-site-association` and `assetlinks.json`
   served from the domain, the Associated Domains entitlement, an
   `autoVerify` intent-filter, and a Flutter deep-link package. Correct,
   and considerably more work.

## FIXED: a brand-new Connect account was marked `disabled`

Found by watching the row rather than the 200. Stripe stamps
`requirements.disabled_reason = "requirements.past_due"` on an Express
account **the moment it is created**, before the photographer has opened
the onboarding form. Both status mappings treated any `disabled_reason`
as disablement, so the first real `account.updated` wrote `disabled`.
Payout approval refuses a non-`active` Connect account, so every
photographer would have been permanently unpayable, with the admin
queue explaining it as "disabled".

A second, opposite bug sat in the same pair. `status_from_account` read
`requirements.disabled_reason`, but the live-read endpoint passes it the
*flattened* dict `connect_status()` returns, where `disabled_reason` is
top-level. That path could therefore never return `disabled` - a
genuinely rejected account read back as `pending_verification` forever.

**Why the tests did not catch it.** Three of them encoded the bug as the
spec, and one was a confident zero:
`test_the_webhook_and_a_live_read_cannot_disagree` transcribed the
webhook's logic into the test body and compared the transcription to
`status_from_account` - two copies of the same idea agreeing with each
other, while the real handler and the real mapper disagreed in opposite
directions on a live account. It imported `webhooks` only to assert it
was not `None`. It now drives `_apply_stripe_event` and asserts on the
row. Both fixes were reverted one at a time and the tests confirmed
failing (3 and 2 failures respectively).

## Rebuilding `api` does not rebuild `worker`

`docker compose build api` builds only the `api` image. `worker` is a
separate service with its own image from the same Dockerfile, so
`docker compose up -d worker` after it restarts the container on the
*old* code. This produced a false negative during Connect verification:
the webhook returned 200, the outbox logged `outbox_event_applied`, and
the row did not move, because the fix was only in the api image. Webhook
effects land in the worker. Always `docker compose build api worker`.

## `GET /v1/pro/me/skills` does write work on every read

The endpoint calls `recompute_pro_niche_skills(db, user.user_id)` with no niche
filter and then `db.commit()`, before it selects anything. That recomputes
**every active niche** - twelve today - and each recompute counts completed
gigs, published reviews, lost disputes in the last 90 days and tagged portfolio
assets for that niche.

That was tolerable while the data sat behind Settings. It is the tier section
of the pro dashboard now, so it fires on every app launch and every
pull-to-refresh: a read endpoint doing twelve niches of write work on the
busiest screen in the app. Fine at twenty photographers, genuinely bad at any
real number.

**Mitigated, not fixed.** The dashboard calls it once through a shared provider
and every block reads that result, rather than each block refetching.

**The actual fix, for whoever picks this up:** recompute on the events that
change the inputs - gig completed, review published, dispute resolved,
portfolio niche tags changed - rather than on read. The machinery already
exists: `enqueue_niche_skill_recalc` publishes a `niche_skill.recalc` outbox
event, and `recompute_pro_niche_skill` takes a single `niche_id`. So the change
is to call the recompute from those event handlers and let the read endpoint
just select. Recomputing one niche on an event that affects one niche also
removes the twelve-way fan-out.

Related: the endpoint returns a row for every active niche regardless of what
the photographer selected, so the app intersects it with
`GET /v1/pro/niches/mine`. Rendering it literally would open a new
photographer's home screen with twelve rookie cards for ten niches they never
chose.

## A photographer cannot stop taking bookings

`ProProfile.is_accepting_bookings` is written in exactly one place -
`POST /v1/pro/me/activate` sets it `True` - and **no endpoint ever sets it back
to `False`**. `ProProfileUpdateRequest` has no such field, and activate takes no
body, so it is a one-way switch.

Discovery filters on `ProPublicIndex.is_accepting_bookings`, so once activated a
photographer is permanently listed as bookable. Someone who breaks an ankle,
goes on holiday, or is simply full has no way to say so.

The workaround that exists is availability: clearing working hours drops
`available_days_next_14` to zero and the funnel refuses the slot. That works,
but it is indirect, it loses the schedule they will want back, and nothing in
the app tells them it is the lever.

The dashboard therefore shows bookable state **read-only** and points at
Availability, rather than offering a switch that cannot save. A dead control is
worse than an honest sentence.

The fix is small - accept `is_accepting_bookings` on the profile update, or add
a pause endpoint - but it is `api/`, so it is recorded rather than made.

## Both flavors ship the default Flutter app icon, from one shared asset set

`ios/Runner/Assets.xcassets` contains a single `AppIcon.appiconset`, shared by
both flavors, still holding the stock Flutter chevrons. So even once there is
artwork, client and pro would install with the *same* icon - two apps a
photographer is meant to tell apart on one home screen.

Deferred deliberately: it needs artwork that does not exist yet. Recorded here
because the shared asset set is the part that will not be obvious later - the
fix is not "drop in an icon", it is "split the set per flavor first", the same
shape as the launch-storyboard split already done in `Client.xcconfig` /
`Pro.xcconfig`.

## Flutter payouts needs `url_launcher`

The payouts screen takes an `openUrl` callback rather than opening the
hosted Stripe URL itself, because opening an external browser needs
`url_launcher` and that is not a dependency of this project yet. The
fallback copies the link to the clipboard and says it expires shortly.
That is honest but poor; the real flow needs the dependency approved.

## ~~`payout.anomaly` froze every photographer's first payout~~ — FIXED

The rule fired when a payout was requested within one hour of money
becoming available. That is a photographer who waited seven days and
withdrew on the day it cleared - the ordinary case, and for most people
the only case. Every first payout would have hit it.

It now measures from the payout account's last change (24 hours), which
is the account takeover the rule was actually defending against: money
landing in a destination someone just swapped in. Settlement timing is
irrelevant to it. Migration `20260905_0045` updates the seeded rule row,
which `ensure_default_risk_rules` would otherwise never revisit.

**The freeze also left no trace.** Verified rather than inferred: over
HTTP the pro was refused and *zero* risk actions existed afterwards;
calling the service directly with a commit produced two. The rule wrote
`freeze_payouts` and `manual_review`, the caller raised a 403
immediately, and the request rollback discarded both - blocking someone's
money with nothing recorded, nothing an admin could find, and nothing to
lift. The freeze is now committed before the refusal.

**And an admin's clear now sticks.** It did not at first: clearing the
freeze let the next request re-trigger the rule while the window was
still open, so the clear was undone within seconds. A clear that reverses
itself is not a clear. The rule now skips a window an admin has already
reviewed; only a *later* account change re-arms it.

## The €144 test entry is spent

The earnings entry from the first end-to-end run has been settled,
requested, approved and marked paid - it is `paid`, and withdrawable is
€0.00. That was the point of exercising the path, but it means **future
payout work needs a freshly settled entry**: complete a booking, let the
settlement scan promote it (or move `available_at` back more than the
anomaly window), and start from there.

Note the anomaly rule when doing so: moving `available_at` no longer
triggers it, but touching `payout_account.updated_at` does.

## Setting `ADMIN_API_KEYS` broke two tests, and my baseline could not see it

Recording the method failure, not just the fix.

Commit `1f388d4a` set `ADMIN_API_KEYS` locally so the admin panel could be
built. Every admin test in the suite sends `X-Admin-Api-Key: ""`, so with
a key configured `require_admin` refused them: two tests in
`test_disputes_refunds` began returning 403 and I reported them as
pre-existing.

**The baseline was wrong in a way that could not fail.** I compared code
at HEAD against code with changes using a git worktree - but ran both arms
in the same container against the same `.env`. The variable that actually
mattered was held constant, so the comparison was guaranteed to show no
difference. It agreed with itself.

Caught only because a 403 turned up in a dispute test where a product
error was expected. The decisive check was one line: run with
`ADMIN_API_KEYS=` unset. 3 failures became 1.

`conftest.py` now forces `ADMIN_API_KEYS=""` for the suite, and
`test_admin_api_key_enforcement.py` covers the guard directly - wrong key
refused, missing key refused, right key accepted - so pinning it for tests
does not leave enforcement uncovered.

**Correction to commit `20870b97`:** it states that `test_disputes_refunds`
"already had these same 3 at HEAD". One was pre-existing; two were mine.

## ~~The dispute-to-refund path was broken in four places~~ — FIXED

Found by walking a real dispute rather than by reading tests. Each defect
was only reachable once the previous one was fixed, so they surfaced one
at a time.

1. **`dispute.category` was `varchar(13)`** while `deliverable_quality`
   (19) and `late_cancellation` (17) are valid values. Opening a dispute
   in the most likely category for a photography marketplace returned a
   500. `refund_case.status` had the same shape - `varchar(10)` against
   `refund_initiated` (16) - which would have stopped the refund one step
   later. Migration `20260905_0046`.

2. **The refund handler forced `gig -> refunded`.** For a dispute the gig
   is already `disputed`, and `disputed -> refunded` is not a permitted
   transition, so the webhook raised, the outbox retried, and it failed
   identically every time. Money had left Stripe and nothing recorded it.
   The handler no longer transitions the gig at all: a `charge.refunded`
   from an admin refund, a client cancellation and a dispute resolution
   are three different things and the handler sees only an amount. If a
   full refund should move the gig, that belongs in the resolution path
   where the intent is known.

3. **Everything scaled to the wrong amount.** The handler assumed every
   refund was full: it marked the payment `refunded`, reversed the
   photographer's entire earnings entry, and wrote a ledger line for the
   whole payment. A €60 refund on a €180 booking would have wiped all
   €144 of the photographer's earnings. Now scaled to what actually came
   back, with the platform fee recalculated on the reduced gross so the
   reduction is shared rather than taken entirely from the photographer.

4. **Finalisation could never match.** `finalize_refund_case_success` used
   `.astext` - JSONB syntax on a plain JSON column - which raised
   `AttributeError` on every call, in both the success and the failure
   path. And for `charge.refunded` the handler passed `obj["id"]`, which
   is the *charge* (`ch_...`), into a lookup on a field holding a refund
   id (`re_...`). Fixed with `as_string()`, a correct per-event-type
   refund id, and a payment-intent fallback for the common case where
   `charge.refunded` arrives without its refunds list expanded.

**A failed event committed its partial mutations.** The dispatcher catches
per row and commits after the loop, so mutations made before a handler
raised were persisted while the event was marked failed. In this case
`payment.status` was left `refunded` by an event that never completed.
Noted previously as theoretical; it is not.

Verified by replaying the genuinely stuck event from its stuck state:
refund case `refunded` with €60.00 recorded, events
`refund_initiated -> refund_succeeded`, ledger gains
`refund_succeeded -60.00`, earnings move 180/36/144 to 120/24/96, gig
stays `disputed`, payment stays `succeeded`.

## "Failed" does not mean "no effect": the outbox dispatcher commits partial mutations

A general property of `dispatch_outbox_events_task`, not something
specific to refunds.

The dispatcher catches exceptions per row, marks that row failed, and
commits once after the loop. Anything a handler mutated *before* it
raised is in the same session and is committed by that commit. So an
event can be recorded as failed while having permanently changed the
database.

Observed concretely: the refund handler set `payment.status = refunded`,
then raised on a forbidden gig transition. The event was marked failed
and retried eight times; the payment stayed `refunded` throughout, on a
booking that had only been partly refunded.

This matters beyond the one case. Every handler is written as though a
raise means nothing happened, and a retry then re-applies whatever did.
Handlers that are not idempotent will double-apply on the retry the
dispatcher performs automatically.

Not fixed here. The options are per-row savepoints (`db.begin_nested()`
around each `_dispatch_event`, rolled back on failure) or making every
handler idempotent. The first is one change and covers all handlers; the
second is correct anyway but is a large audit. Worth deciding before
launch - the dispatcher drains the money path.

## ~~Enum column widths~~ — FIXED, and alembic could not be trusted to find them

`Enum(..., native_enum=False)` sizes its VARCHAR to the longest enum
**member name** at the moment the migration is generated, and nothing
resizes it when a longer value is added later. Two columns had already
outgrown their width; **162 more sat exactly at their limit**, one new
enum value away from the same 500.

Every model now pins `length=64` explicitly, so the width is a decision
rather than a side effect of whichever names existed when the column was
created, and migration `20260905_0048` brings the database to match.
Widening a varchar in Postgres is catalog-only - no table rewrite - so it
is cheap even on large tables. Result: 164 enum columns, 0 broken, 0 at
limit.

**Alembic's numbers were unreliable for exactly this.** It compares
against member names, not stored values. `feature_flag.scope` and
`milestone.scope` hold `'global'` (6 characters) but their member is
`global_scope` (12), so alembic reports them as too narrow when they are
not. A mechanical make-the-database-match-the-model pass would have
widened them for no reason - and, worse, would have taught us to trust
the tool on the next column. Every width in this pass was verified
against `enum.value`.

Demonstrated rather than argued: a 30-character value now writes to
`dispute.category` at the database level, and the ORM correctly refuses
to read back a value not in the enum. Headroom and validation are
separate concerns and both behave.

## Models said JSON, the database has always held JSONB — FIXED

142 of the 146 type differences alembic reported were one decision
repeated: the models declared `JSON` while every column is `JSONB`. The
models were the accidental state - the evidence being that
`finalize_refund_case_success` was written with `.astext`, which is JSONB
syntax, and crashed. Changing the models rather than the database means
no migration and no table rewrite, and `.astext` is correct again.

Drift went from 207 differences to 68, all now index and constraint
shape.

## Remaining drift: index and constraint shape (~68)

Not addressed in this pass, deliberately. 23 changed indexes, 22 removed
unique constraints and 11 removed indexes are largely the same handful of
facts expressed two ways - a `UniqueConstraint` in the model against a
unique index in the database. Each needs reading individually, which is
exactly the sort of work that goes wrong when done mechanically.

One genuine type difference remains: `vault_item.bytes` is BIGINT in the
database and `Integer` in the model.

`alembic check` cannot gate CI until this is reconciled. Worth a pass of
its own with the numbers above as the starting point.

## No video poster frames in the portfolio preview

`ClientProProfileResponse.portfolio_preview` resolves a signed thumbnail for photos, but portfolio **videos** are served through Mux and have no `MediaObject` rows behind them, so `thumbnail_url` is always null for `kind == "video"`. The pieces to fix it exist — `asset.meta["playback_id"]` and `create_mux_playback_token` — but Mux's image service (`image.mux.com/{playback_id}/thumbnail.jpg`) needs its own signed token, separate from the playback token, so it isn't a one-liner.

Low urgency: `portfolio_video_count` is 0 for every seeded pro and video upload is behind the `video_uploads_enabled` flag. It becomes visible the first time a pro uploads a reel.

## Unenforced schema shapes: `ClientPreferenceView.location` and `top_niches`

Two payload shapes the client app depends on are conventions rather than contracts. Both are read defensively in Flutter, which is the right call for now, but neither is protected against a writer that disagrees.

1. **`ClientPreferenceView.location` is `dict`** (`api/app/schemas/client_launch.py`) — untyped, `additionalProperties: true` in the OpenAPI schema. The whole client app is gated on a browse location, which is read out of this object as `{"country": ..., "city": ...}`. That key convention exists only in the seed data and in the two places that write it. Anything that writes a different shape — an admin tool, a migration, a future preferences screen — silently returns the client app to the "where are you looking?" prompt with no error anywhere. `BrowseLocation.fromPreferenceLocation` treats a shape it doesn't recognise as "not set", so the failure is at least benign, but it's invisible.

2. **`ClientDiscoverCard.top_niches` is `list[dict]`** — generates as `List<Map<String, dynamic>>`, so every key access is untyped. The rows carry `slug`, `tier`, `score`, `verified`, `capability`, `confidence`; the card reads `slug` and skips any entry where it isn't a non-empty string.

3. **`ClientBookingStatusResponse.timeline` is `list[dict]`** — same shape problem, found while building the booking detail screen. The backend writes `at`, `from`, `to`, `reason`; the app parses defensively and drops rows missing a usable `at` or `to` rather than rendering "null → null".

**Fix:** give both a real Pydantic model (`ClientLocation`, `ProNicheSummary`). That is a breaking schema change for any existing writer of a differently-shaped `location`, so it wants a migration audit first, not a drive-by edit.

## LAUNCH BLOCKER: the tier price cap enforces nothing — zero rows

The entry price cap is the mechanic the whole pricing engine hangs off: the
per-niche decay curve prices a package upward from an entry price, and the cap
is what stops a photographer choosing an entry price their standing has not
earned. **`niche_package_price_cap` has zero rows**, and
`enforce_entry_price_cap` treats an unconfigured (niche, tier) as no
restriction and returns early.

So today **a rookie can price at master rates**, and - because the cap carries
`entry_price_min` as well as `entry_price_max` - can also undercut the floor.
Neither direction is checked. The enforcement is built, correct, and inert.

`extra_image_pricing_policy` is empty in the same way:
`enforce_max_extra_images` finds no policy and returns, so the per-tier ceiling
on extra images is not applied either.

This is not a card-copy problem. It is the quality thesis not being enforced:
the ladder is fully computed, demotion has hysteresis, admin overrides are
audited - and the one consequence a photographer would feel in their pricing
does nothing. The only live effect of tier is discovery placement
(`recompute_pro_public_index` adds `tier_rank * 8` to `ranking_score`), which
is why the dashboard's tier card claims placement and nothing else. One false
claim would make every true one suspect.

**This is a data task, not a code task.** The enforcement is waiting on rows.

`niche_package_price_cap` needs one row per (niche, tier) to be enforced -
5 tiers across the 12 active niches, 60 rows for full coverage, though a
partial set is valid: an unconfigured pair simply stays unrestricted.

| column | notes |
| --- | --- |
| `niche_id` | FK to `niche.id` |
| `tier` | `rookie` / `skilled` / `pro` / `elite` / `master` |
| `entry_price_min` | numeric(12,2), NOT NULL, defaults 0.00 — the floor, enforced |
| `entry_price_max` | numeric(12,2), nullable — null means no ceiling |
| `currency` | char(3), defaults `EUR` |

Unique on `(niche_id, tier)`. Active niches: `architecture`, `automotive`,
`corporate`, `events_nightlife`, `family`, `food`, `maternity`, `portraits`,
`product`, `real_estate`, `sports`, `weddings`.

`PUT /v1/admin/pricing/niche-package-price-caps` already exists to write them.

Once the rows exist, the tier card can honestly say a tier raises what a
photographer can charge. Until then it must not.

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

## The watermark has never actually watermarked anything (FIXED, but existing objects need a backfill)

Found while planning the fullscreen photo viewer. Three separate faults stacked on top of each other, and all of them were invisible because galleries have only ever been rendered as 512px thumbnails.

**1. No font is installed in the API/worker image.** `_draw_watermark` asked for `/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf` at `image.width // 22` — 194px on a full-frame photo — caught the `OSError`, and fell back to `ImageFont.load_default()`. That fallback *ignores the requested size* and renders a ~8px bitmap face: "RAWWERS" measures **50x8 pixels**. On a 4288px photo the mark covered **0.0145% of the frame**. Every watermarked preview this pipeline has ever produced, in dev and in production, is effectively unmarked. `find / -name "*.ttf"` in the running container returns nothing.

**2. The mark was a single line in one corner**, so a crop removed it at zero cost to the thief. Measured per quadrant on a 1600px frame: top-left, top-right and bottom-left were **0.0000%** marked.

**3. The "preview" was full resolution.** `watermark_preview` and `preview_watermarked` were written from `image.copy()` with no downscale, while `web_res` — which is only served *after* the client holds the entitlement — was capped at 2048px. So the unpaid preview was larger than the paid deliverable. Confirmed in the dev database: `watermark_preview` rows up to **4288px**.

**Fixed** in `app/tasks/media_tasks.py`: previews are downscaled to `WATERMARK_PREVIEW_MAX_PX` (1600) before marking; the mark is tiled diagonally across the whole frame with half-step row offsets; and `_load_font` falls back to `ImageFont.load_default(size=size)`, which is scalable in Pillow 10.1+, so no font package is needed. Covered by `tests/test_gallery_media_delivery.py`, each check verified to fail against the previous implementation.

**Still outstanding — the backfill.** Fixing the pipeline does not fix what is already in the bucket. `scripts/backfill_watermark_previews.py` re-renders oversized previews from their originals; it reports by default and overwrites only with `--apply`. It has **not** been run against any environment. Dev currently holds 6 oversized `watermark_preview` objects and 6 oversized `preview_watermarked` derivatives. Production has not been counted.

**Also note:** the worker runs from a separate image built from the same Dockerfile, and `docker compose build api` does not rebuild it (see the entry above). The watermark change only takes effect for newly processed uploads once the **worker** is rebuilt.

## Presigned gallery URLs expired mid-selection (FIXED)

`get_gallery` signed both the thumbnail and the watermarked preview with `expires_in=300`. A client comparing 200 wedding photos is still deciding well after five minutes, at which point already-rendered images start returning 403 with nothing on screen to explain it. Now signed with `GALLERY_PREVIEW_URL_TTL_SECONDS` (3600) — safe specifically because these point at downscaled, watermarked previews. The finals keep their short window (`media_rights._signed_ttl_seconds`, clamped 60-300s); nothing about this touches them.

## `get_gallery` was N+1 over the whole gallery (FIXED)

Two `MediaObject` queries plus two presigns per item, in a Python loop. Measured against the local backend: 5 items / 0 presigns = 31.8ms; 14 items / 28 presigns = 74.0ms, i.e. ~4.7ms per item, extrapolating to **~970ms and ~400 queries for a 200-photo gallery**. Signing itself is a local HMAC and costs nothing — the cost was the query loop. Replaced with `resolve_variant_urls`, one query for the page, mirroring the `resolve_image_urls` fix already applied to Discover cards. A regression test asserts the query count does not grow with the number of photos; against the old code it measured 16 queries for 3 photos and 46 for 18.

**The same shape still exists in `GET /v1/pro/{id}/public-profile`** (`app/api/v1/discovery.py:283-304`) — two `MediaObject` queries and two presigns per portfolio photo, also at 300s. Left alone because it was outside the authorised scope of this change; it is capped at a smaller page than a proof gallery, but it is the same bug.

## `ProPortfolioItem` carries no full-resolution URL (blocks fullscreen on the pro's own portfolio)

`GET /v1/pro/me/portfolio` returns only `thumbnail_url`, resolved via `resolve_image_urls` with the default `THUMBNAIL_FIRST` — a 512px image. A fullscreen viewer on the pro's own portfolio has nothing larger to show, so it would either display a 512px image blown up across a phone or need a second call per photo. Needs either a `preview_url` on `ProPortfolioItem` or a `prefer=ORIGINAL_FIRST` companion field. Not changed here: it is a schema change and was outside the authorised scope.

## The test suite was running against live Stripe and R2 credentials

**This entry replaces an earlier one that said "60 unconditional failures, 28 of them a `user_role` FK". Both numbers were wrong.** The 28 came from an OR'd `grep -c` counting *log lines* - the string `is not present in table "user_account"` appears in the captured logs of tests that fail for unrelated reasons - so a line count was reported as a test count. The real figure for that constraint was 1. More importantly, most of the failures were not the code's fault at all; they were an artifact of where the suite was being run.

`tests/conftest.py` set 43 environment variables with `os.environ.setdefault`, which is a no-op whenever the variable already exists. Run inside the api container - where `.env` has already populated everything - **21 of those defaults never applied**:

| variable | conftest intends | container supplies |
| --- | --- | --- |
| `ADMIN_USER_IDS` | the test admin uuid | *empty string* |
| `STRIPE_WEBHOOK_ALLOW_UNVERIFIED` | `true` | `false` |
| `STRIPE_SECRET_KEY` | `sk_test_123` | a real key |
| `R2_BUCKET` + keys | `bucket` / `test` | `rawwers-media` + live credentials |

Three consequences, in order of seriousness:

1. **Tests reached live external services.** `test_a_window_only_partly_blocked_can_still_be_accepted` calls `accept_booking_request`, which reaches `stripe.PaymentIntent.create` with no mock anywhere in the file. With a real key in the environment it was creating real PaymentIntents on every run, and passing because of it. Likewise `R2_*` pointed at the live media bucket, which is how a maintenance script run in that container overwrote six real objects.
2. `ADMIN_USER_IDS` arriving empty meant `_seed_admin_role_if_needed` seeded nothing, so `require_admin` answered 403 and 17 tests failed looking like broken authorization.
3. `STRIPE_WEBHOOK_ALLOW_UNVERIFIED=false` produced 4 more failures as 401s.

conftest had already learned this exact lesson for `DATABASE_URL` alone, with a comment describing the identical trap - "setdefault only takes effect when DATABASE_URL is *unset*, and the environment where that protection actually matters is precisely the one where it is always set: inside the api container". It was never generalised. It is now: 40 variables are forced by explicit assignment, and `REDIS_URL`, `LOG_LEVEL` and `APP_ENV` stay as defaults because those are infrastructure the surrounding environment legitimately owns.

## Parent rows are not reliably inserted before the children that reference them

Adding a `UserAccount` and a `ProProfile` to one session and committing them together fails on `pro_profile_user_id_fkey`, even though `ProProfile.user_id` declares `ForeignKey("user_account.user_id")`. Demonstrated directly: the one-shot commit raises, and inserting a `flush()` between the two succeeds. Seven test helpers had that shape and 12 tests failed on it; each now flushes the parent explicitly, which is what the application code does anyway via `ensure_user_account`.

Worth understanding properly rather than working around forever - the unit-of-work sort should handle this, and something about these mappings defeats it.

## Two discovery gates, and the fixtures only knew about one

Being visible in Discover takes five conditions, and `GET /v1/discover/pros` (and `GET /v1/search/pros`) enforce the fifth with a join on `ProOnboarding.status == approved_public` - a publish gate entirely separate from `ProProfile.kyc_status`. Fixtures in `test_discovery.py` and `test_search_api_fallback.py` never created a `ProOnboarding` row, so the join removed every pro and the endpoints returned nothing at all. These tests cannot have passed since that join was added.

Both fixtures now grant `approved_public` to *every* seeded pro, so exclusion is decided by the property under test. Granting it only to the pro expected to appear would leave the test passing while asserting nothing.

## The suite: 62 failures down to 33

Full runs, `-p no:randomly`, same database:

| | failed | passed |
| --- | --- | --- |
| baseline at `f2a036a9` | 62 | 270 |
| after forcing the test environment | 40 | 308 |
| after the fixture fixes above | 33 | 315 |

What remains has no dominant cause left - the largest group is 6, and those six are unrelated to each other. It is ordinary accumulated test debt plus a handful of genuine bugs, and it now needs reading test by test rather than in clusters. Until it reaches zero the suite still cannot answer "did my change break something" on its own, and the procedure remains a full run diffed against a baseline.

## The suite takes ~24 minutes because it rebuilds the schema 334 times

`conftest.setup_database` runs `Base.metadata.drop_all` + `create_all` per test, at ~4s each across 334 tests. A transaction-per-test fixture that rolls back instead would cut this to well under a minute. It also makes the run fragile: every test takes an exclusive lock on every table, so one session left idle-in-transaction (an interrupted run, a killed process) blocks the next run's `DROP TABLE` indefinitely rather than failing fast. That happened during this work and presented as a hang, not an error.

## The test environment now refuses to run against anything real

Forcing the variables was necessary but not sufficient: a forced value is still just a value, and anyone adding a new one - or running the suite somewhere that sets these another way - gets production back. `tests/conftest.py` now fails collection outright if the resolved environment could reach anything real, in the same shape as the existing database guard:

- `_assert_storage_is_not_real` rejects an `R2_BUCKET` that is neither `bucket` nor `*-test`, and any `R2_ENDPOINT_URL` pointing at a real cloudflarestorage host.
- `_assert_stripe_is_not_real` rejects a live key, and also a genuine test-mode key belonging to an account - the suite's placeholder is the only accepted value, because tests should not reach Stripe at all.
- `stripe.api_base` is pointed at `http://stripe.invalid`, so an unmocked call fails immediately at DNS instead of leaving the machine. Verified: `test_a_window_only_partly_blocked_can_still_be_accepted` now fails locally in milliseconds rather than creating a real PaymentIntent.

Each guard was checked against the real values it exists to reject, not only the safe ones.

## Missing imports have taken out four separate paths

`log_event` in `media_rights.py` was the third instance of this shape after the KYC 500 and the GearCategory one, and a sweep turned up a fourth: `CurrentUser` used as an annotation five times in `app/api/v1/i18n.py` and never imported. That one is latent rather than live - `from __future__ import annotations` defers evaluation and FastAPI leaves it as an unresolved `ForwardRef` - but deleting that future import, or anything calling `get_type_hints` on those handlers, turns it into a `NameError`.

Python does not catch this at import time when the name sits in a function body or a deferred annotation, so nothing fails until the line runs. `tests/test_no_unbound_names.py` now walks every module in `app/` and fails on any name loaded but never bound, with a companion test that feeds it the shape of the real bug to prove it still catches one.

## `ProPortfolioItem` still blocks fullscreen on the pro's own portfolio

The fullscreen viewer is wired into the delivery gallery, which carries `watermark_preview_url` - now a 1600px image after the watermark fix, which is exactly what a photographer needs to check focus before publishing.

The pro's own portfolio cannot use it yet. `GET /v1/pro/me/portfolio` returns `thumbnail_url` only, resolved with the default `THUMBNAIL_FIRST`, so the largest image available is 512px. Opening that fullscreen shows a 512px image stretched across a phone, which is worse than not offering the gesture. The photos do have larger variants - `process_photo_variants` writes `watermark_preview` for every photo regardless of purpose - they are simply not exposed on this response.

Needs one field on `ProPortfolioItem` (a `preview_url`, resolved the way the proof gallery resolves its own) plus a client regeneration. Not made here: it is a schema change and was outside the authorised scope.

## The watermark fix is now actually in the bucket (RESOLVED)

Both halves of item 1 are in effect, not just committed:

- **The worker image was rebuilt.** `docker compose build api` does not rebuild `worker` - they are separate images from the same Dockerfile - so until `build api worker`, every newly uploaded photo still got the old corner mark at full resolution. Verified after recreate: the worker now has `WATERMARK_PREVIEW_MAX_PX` and the scalable font fallback.
- **The backfill ran.** 6 oversized `preview_watermarked` derivatives rewritten (3000-4288px down to 1600), rebuilt from their intact originals. Dry run first: 6 to rewrite, 0 blocked, 0 skipped. Afterwards nothing in the bucket exceeds the limit, `original` and `full_res` are untouched at 124 and 116 rows, and `web_res` remains 2048. One rewritten object was pulled back out of R2 and looked at: 1600x1200, mark tiled across the whole frame, photograph still perfectly judgeable.

**Rebuilding the image removed pytest (FIXED).** The Dockerfile ran `poetry install --without dev`, so a freshly built image had no test dependencies - the image the suite had been running in all along predated that flag, and rebuilding the API silently removed the ability to test it. That is the kind of fault that surfaces mid-incident rather than in review.

The Dockerfile is now two stages: `runtime` is what ships, and `dev` extends it with the dev group. `docker-compose.yml` selects `${BUILD_TARGET:-runtime}`, and `api/.env` (git-ignored, local only) sets `BUILD_TARGET=dev`. A server that never sets it keeps the lean image, so production cannot pick up test dependencies by accident. Verified both ways: a clean rebuild and recreate leaves `pytest 8.4.2` in the local container, and `docker build --target runtime` produces an image where `python -m pytest` reports no such module.

## Finals download URLs expired in 60 seconds (FIXED)

`get_download_links` signed with `expires_in=60`. A real save is tap, share sheet, choose a destination, wait for the write - easily over a minute on a slow connection - so the link could expire mid-save, and a 403 there lands immediately after the client has paid. Now `FINALS_DOWNLOAD_URL_TTL_SECONDS` (600), deliberately far shorter than the hour a preview gets: a preview is downscaled and watermarked, a final is the photograph itself. The app asks for a fresh link per download rather than reusing one minted at page load, which the 20-per-minute rate limit comfortably allows.

The same endpoint was also the last per-item presign loop in the codebase - one `MediaObject` query per photo, on the path a client uses after paying. Now batched through `resolve_variant_urls` like the gallery and portfolio endpoints.

## `/v1/discover/pros` returns no cover image for anyone

Found while verifying the seeded photographers surfaced. The endpoint builds each `ProCard` without ever setting `cover_media_asset_id` or `cover_url`; both fields exist on the schema and default to null, so every card comes back image-less however good the underlying data is.

**Not currently urgent, and worth knowing why:** the Flutter client calls `/v1/client/discover`, which resolves covers correctly through `_cards_from_index`. This route is not used by the app. Reported rather than fixed because it is dead code, and fixing unused endpoints is how dead code acquires the appearance of being load-bearing.

**It is a trap for the Netflix-style rows in Part 1.** A horizontal photo row reaching for this endpoint would render a wall of blank cards, and the cause - a card builder silently omitting two fields - looks nothing like the symptom. Cheap to write down now, expensive to rediscover after the rows are built.

## Editing the discovery index without recomputing serves a stale home screen

The client home and discover responses are cached in Redis under a key containing `get_public_index_version()`, and that version is bumped in exactly one place: the end of `recompute_pro_public_index`. Any path that changes what should appear in Discover **without** going through that function leaves the cached response in place until its TTL expires.

Found while writing tests for the rows endpoint. Six tests failed together and every one of them passed in isolation: the per-test database wipe does not touch Redis, so each test was being served the previous test's answer under an unchanged version key. The tests now flush the cache themselves, but the tests are not the point.

**Why it matters in production:** the symptom is "this photographer was approved days ago and still is not showing", with nothing wrong in the database, nothing wrong in the query, and nothing in the logs. Anyone debugging it looks at the gates - which all pass - rather than at a cache key that never moved. Direct admin edits, data migrations, and any future background job that touches `ProPublicIndex` all have this shape.

**Options, in rough order of preference:**

1. Bump the version inside a SQLAlchemy `after_update` hook on `ProPublicIndex`, so it is impossible to change the row without invalidating the cache. Structural rather than remembered, and the same argument as the seed guard sitting on the shared path rather than in each entry point.
2. Include a cheap `max(updated_at)` for the city in the cache key, so any row edit changes the key naturally.
3. Shorten the TTL. Cheapest, and only narrows the window rather than closing it.

Not fixed here: the rows endpoint does not introduce the behaviour, it only made it visible, and changing cache invalidation touches every discovery read.

## DEPLOY REQUIREMENT: recompute every `min_package_price` before trusting the budget filter

`min_package_price` changed meaning. It was `min(ProPackage.price)` - a per-photo entry rate - and is now the starting total for the cheapest package, via `compute_minimum_amount`. Every reader inherits that automatically **only once the row is recomputed**, and nothing forces the recompute to happen when the code ships.

**This is not a display concern.** The column gates discoverability, backs the `min_price`/`max_price` budget filter, and drives `price_asc`/`price_desc` sorting. Until a row is reindexed it answers those queries in the old unit.

**What it looks like when it happens:** some photographers respond correctly to a budget filter and others do not. A search for "under EUR 500" returns a handful of people whose rows still hold a per-photo rate, and omits everyone already migrated. No error anywhere, nothing in the logs, and the result reads as thin inventory rather than as a broken filter. Sorting by price interleaves two units, so the order is meaningless without looking wrong.

Caught locally exactly this way: three photographers had been recomputed and the rest had not, so `EUR 0-500` returned ten people whose real starting totals are in the thousands.

**What closes it:** a bulk recompute of every `ProPublicIndex` row as part of deploying this change - a migration step or a one-off script run during the deploy, not the natural reindex cadence. `recompute_pro_public_index(db, pro_user_id)` for every row is sufficient; locally that was 56 rows and a few seconds. Until it has run, Discover's budget filter and price sort are mixing units and must not be trusted.

The general shape is the one already recorded for the discovery cache: a derived value that does not update itself when the thing deriving it changes. The code change and the data migration are separate events, and nothing in the system makes them happen together.

## DEPLOY REQUIREMENT: recompute every `ranking_score` after the response-time change

The response bonus is gone from `ranking_score` (+10 for an average reply under an hour, +5 under three). How fast someone replies is now a label on cards and profiles, never an input to ordering - see `app/services/response_time.py`. Migration `20261007_0056` backfills the new `response_bucket` and `response_median_minutes` in SQL, so the **labels** are right from the first request after deploy. It does **not** touch `ranking_score`: every stored score keeps its old bonus until that photographer's row is next recomputed, and that happens only when something about them changes.

**What it looks like if skipped:** photographers who once replied quickly stay up to 10 points ahead of identical ones indefinitely, and a later recompute - triggered by an unrelated edit, a review, a request resolving - drops them several places with no visible cause. On dev data that is one photographer, who falls from 10th to 14th in Lisbon's ranking-ordered row and so out of its top 12. No niche row changes order.

**What closes it:** the same bulk recompute as the `min_package_price` entry above - `POST /v1/admin/index/pro/rebuild-all` (queues `rebuild_all_pro_indexes`), or `recompute_pro_public_index` over every row - run as part of this deploy. One run covers both entries. It also bumps the public index version, so cached home and discover responses stop serving the old order.

## Eleven test failures that predate the price-cap work

Recorded so they are not mistaken for fallout from the cap enforcement, the
tier-resolver move, or the seed changes. None were introduced by them, and
none are fixed.

**Established by comparison, not assertion.** The same `-k` subset was run
before and after the resolver move and produced an identical five failures,
same names and same counts. A wider subset then surfaced six more, in files
that had not been run at all that session. Neither of the two inspected goes
through `resolve_pro_tier_for_niche`: `activate_pro` does not call it and
neither does `recompute_pro_niche_skills`, so the move cannot reach them.

Diagnosed:

- `test_client_rewards_pricing::test_tier_based_price_clamp_and_master_no_cap`
  does `select(Niche.id).scalar_one()`, which expects a single niche. The
  harness seeds the whole catalogue, so it raises `MultipleResultsFound`.
  Written when the catalogue had one row.
- `test_niche_skill_matrix_v2::test_extra_image_price_cap_uses_niche_tier`
  passes `title=` to `ProofGallery`, which no longer accepts it. Stale
  against the model.
- `test_pro_onboarding_booking::test_pro_cannot_activate_without_kyc_in_production`
  gets 401 where it expects 409, so it fails at authentication before
  reaching the behaviour under test.
- `test_niche_skill_matrix_v2::test_tier_assignment_respects_verified_requirement`
  expects a promotion to pro or above and gets skilled. This is about what
  `recompute_pro_niche_skills` **writes**, not what the resolver **reads**.

Not yet diagnosed: `test_chat_concierge::test_ai_reply_is_grounded_to_snapshot_packages`,
`test_niches_skills::test_discovery_niche_filter_orders_by_tier_before_rank`,
`test_pro_availability_and_listing::test_listing_preview_reflects_a_pricing_edit`,
`test_launch_ops::test_onboarding_transitions_requirements_and_approve_triggers_events`,
`test_learning_v0::test_certification_completion_triggers_niche_skill_recompute`,
`test_niche_skill_matrix_v2::test_hysteresis_blocks_rapid_promotion_flip`,
`test_niche_skill_matrix_v2::test_badge_award_and_revoke_current_only`.

**Why it is worth a section.** Four of the eleven carry tier or pricing in
their names, so anyone running the suite after this arc will reasonably
suspect the cap work first. The two stale ones above are both a test frozen
against an older schema rather than a defect in shipped code, and the rest
should be triaged on that assumption before any other.

**Running the suite at all needs a flag.** The container has no bind mounts,
so a script change needs `docker compose build api` before it takes effect -
a stale image already produced one false "the seed changed nothing" result
this session. And `TEST_DATABASE_URL` must point at the `postgres` host
rather than the default `localhost`, or every test errors during fixture
setup with a connection refusal that looks nothing like a configuration
problem:

    docker compose exec -e TEST_DATABASE_URL="postgresql+psycopg2://postgres:postgres@postgres:5432/rawwers_test" api python -m pytest tests/ -q

## The accept endpoint's body is optional server-side and required in the app

`POST /v1/booking-requests/{id}/accept` gained an optional body carrying the
per-booking client-credit override. Every field on it has a default, so the
endpoint is still callable with no body at all - which is how it had always
been called.

`swagger_to_dart` generated `requestBody` as a **required** parameter anyway,
so the Flutter caller now always sends one, passing a null override to mean
"use the photographer's default".

Harmless today: a body of `{"client_credit_percent": null}` and no body at
all produce the same split. Worth writing down because the two sides disagree
about whether the body is optional, and that stops being harmless the moment
something depends on the distinction - a future caller that genuinely wants
to send no body, or a change that makes an absent field mean something other
than a null one.

If it needs fixing later, the fix is on the generator side or by marking the
body explicitly optional in the OpenAPI schema, not by making the field
non-null in the app.

## Tables built before anything reads them, and the five that remain

A recurring habit, not an incident. Four times this session a feature's data
model turned out to exist while nothing read or wrote it, and each was found
by accident rather than by looking:

- `niche_package_price_cap` was empty, so `enforce_entry_price_cap` returned
  on its first line every time it was called. The ceiling had never existed.
- the watermark pipeline wrote a mark nobody could see, at a size and
  position nothing checked.
- `ProNiche` rows were never created, so the per-niche description added on
  top of them would have been null for every photographer.
- `tax_profile` carries a `vat_number` and has no reader, no writer, no
  endpoint, and zero rows.

Each discovery cost more than looking would have, so here is the look.

**The sweep.** Every mapped table, counted, then grepped for references
outside `app/models/` and `app/db/base.py`:

    218 tables      117 empty      5 empty with no reader or writer

The five:

| model | table | why it is still here |
|---|---|---|
| `TaxProfile` | `tax_profile` | being adopted now, for the UK VAT work |
| `DisputeEvidence` | `dispute_evidence` | disputes exist; evidence was never built |
| `PackagePricing` | `package_pricing` | superseded by `package_decay_curve` and `niche_package_price_cap` |
| `StripeWebhookEvent` | `stripe_webhook_event` | superseded by `IdempotencyKey`, which is what actually dedupes Stripe events |
| `WebhookEvent` | `webhook_event` | same, for the generic ingest path |

Checked for raw-SQL access by table name as well as by class: all five have
zero references of either kind.

**What to do with them.** `TaxProfile` is being used. The other four are
either unbuilt (`dispute_evidence`) or genuinely superseded, and superseded
tables are worse than missing ones: a future reader can find
`StripeWebhookEvent`, conclude that is where Stripe events are recorded, and
be wrong. Dropping the three superseded ones is a migration nobody has asked
for yet, so this is a record rather than a change.

**Worth re-running.** The sweep is two greps and a row count. It belongs in
whatever check runs before a release, because the cost of this pattern is not
the empty table - it is building on top of one and finding out later.

## Lighting is declared, not verified, and that gate is unevenly enforced

Gear verification proves a camera body and a lens from EXIF: the model is
looked up in a reference table for its sensor size, and `LensSpecification`
states the maximum aperture at each end of the focal range, which
distinguishes a prime and a constant-aperture zoom from a variable one.

**Nothing in a photograph identifies the strobe that lit it.** There is no
EXIF tag for a light. So the lighting requirement - which applies to
weddings, product and food - rests on the photographer's own word.

Recorded rather than hidden. Lighting lands in its own `declared` status,
never `verified`, and the floor evaluation reports `lighting_is_declared` so
no screen can present the two with equal weight. A test fails if a lighting
claim is ever written as verified, and another fails if a `declared` row is
ever allowed to satisfy the body or lens requirement.

**Accepted, not solved.** The alternatives were considered and deliberately
not built: requiring a photograph of the equipment itself would put a human
in front of something real but proves ownership no better than a receipt
does, and it adds a queue, an upload flow and a judgement call to a task that
is already large.

**What would close it**, if it ever matters enough: a photo of the unit with
its serial visible, reviewed by hand, which is the same mechanism the
missing-EXIF-serial case already needs. The two should be built together
rather than separately, since they are the same queue and the same judgement.

The honest framing for now is that this gate is uniform in what it requires
and uneven in what it can prove, and it says so everywhere it appears.

## ~~Finals were released before they were paid for, and a selection could be enlarged after the fact~~ — FIXED

Three defects with one root, found by tracing what happens when a client
*comes back* to a selection rather than the first pass through it. None of it
was visible from the happy path, and the existing
`test_declined_difference_charge_leaves_gig_open` asserted gig and gallery
status only - it never asked whether a download was refused, so it passed with
the gate wide open.

1. **Curve-priced downloads never checked payment.** `98ead30` removed the
   "succeeded UpsellPurchase" requirement from the unlock paths to stop photos
   being billed twice, and never added the difference-payment requirement in
   its place. `submit_selection` also granted `download_finals` and marked the
   selection submitted *before* the difference PaymentIntent was confirmed.
2. **The difference intent went stale.** `create_or_get_gig_payment_intent`
   returned any existing difference payment without looking at its amount, on a
   fixed idempotency key. Submit 25, abandon, come back and submit 30, and the
   client got the 25-photograph intent: the app quoted one price, Stripe took
   another, and `payment.amount` (which the ledger reads) recorded a third.
3. **A completed booking accepted a new selection.** `save_selection` allowed
   `selection_submitted` galleries. Reproduced: pay for 25, save 30, resubmit,
   get the already-succeeded intent's dead secret, and `/downloads` returns 30.

**Fixed.**

- `unlocked_final_asset_ids` is the single boundary for releasing finals; the
  downloads endpoint, the signed-URL path and share-link scoping all go through
  it, and `/downloads` no longer carries its own copy of the rules.
- `is_selection_fully_paid` compares *amounts*: succeeded difference payments
  must sum to `amount_final - amount_minimum`, and the base payment must have
  succeeded (the quote's `amount_paid` assumed it).
- A curve-priced booking's `download_finals` entitlement is granted in
  `finalize_gallery_and_complete_gig`, when it is paid, not at submit, so
  `list_gig_media` does not advertise files the download paths would refuse.
- The difference intent is reconciled to the balance owed now. Rules verified
  against Stripe test mode, not assumed: `PaymentIntent.modify(amount)` works
  from `requires_payment_method` (fresh or after a decline) and keeps the client
  secret; from `requires_action` it silently moves the intent to
  `requires_confirmation`, so those are cancelled and replaced; `processing` and
  `succeeded` are refused with a 409. A replacement needs its own idempotency
  key, because Stripe rejects a reused key with different parameters.
- `save_selection` and `submit_selection` require `published`. A gallery still
  awaiting its payment is still `published`, so re-entry after a decline or a
  killed app keeps working.
- The selection quote subtracts difference money already collected, so the
  quote and the charge stay one number when a payment arrived short.
- `payment_intent.succeeded` compares `amount_received` with the stored amount.
  On a mismatch it records `meta.amount_mismatch`, writes an `admin_audit_log`
  row (`stripe_amount_mismatch`), logs a warning, and stores what Stripe
  actually collected. This is the observability the stale-intent bug lacked.

Tests: `tests/test_download_payment_gate.py`. Ten of the first fourteen failed
against unchanged code; four controls (paying unlocks, nothing-owed downloads,
summing payments, matching amounts) passed, guarding against an over-strict fix.
Each of fourteen deliberate breakages of the fix turns at least one test red.

**Still open, and worth knowing:**

- **A short payment has no surface in the app.** The ledger now records what
  Stripe took, so an underpayment leaves the booking open with a real shortfall
  and the quote names it - but nothing tells the client, and the selection
  screen starts empty on re-entry (the server has no read for the current
  selection). Recoverable by re-selecting and submitting; not discoverable.
- **A payment stuck in `processing`** blocks a re-submit with a 409 until it
  clears. Correct, and a candidate for the Multibanco work already recorded
  above, where `payment_intent.processing` is not handled at all.

## Platform fee is re-booked on every payment, including the difference - NOT VERIFIED

Noticed while reading the success webhook, outside the scope of the change
above and deliberately not touched. `payment_intent.succeeded` writes
`platform_fee = min(gig.amount_platform_fee, payment.amount)` to the ledger for
*every* base and difference payment. `gig.amount_platform_fee` is the fee on the
deposit, so a difference payment appears to recognise it a second time. The
earnings entry (`create_earnings_entry`, from the split on the whole gross) is a
separate path and may be right; this is the `LedgerEntryType.platform_fee` line
only. Needs its own discovery: run a curve booking with a difference charge and
compare the ledger's fee total with `amount_platform_fee` and with the earnings
split.

## The legacy upsell intent has the same shape, at lower exposure - LOGGED

`_ensure_upsell_intent` returns an existing intent for the *same selection* and
updates our row's amount without ever modifying the Stripe intent. It is keyed
per selection, so it only goes stale when pricing configuration or a
points-redemption discount changes between creating and paying, not on every
reselection. Only non-curve bookings (created through `POST /v1/gigs`) reach it.
Not fixed: much smaller exposure, and it would widen the change above.

## ~~`test_rate_limit_named_buckets_enforced` can only pass once an hour~~ — FIXED

It uses a fixed principal (`test-principal`) against the real Redis with a
3600-second window, and nothing clears the key afterwards, so the second run
inside the hour starts already over the limit and fails - at HEAD as well as
with any change. It looks like a regression in whichever change was made just
before the second run, which is how it surfaced during the download-gate work:
two failures that were absent from one full run and present in the next, with
no code path in common. Fix is a unique principal per run (a `uuid4()`), which
is what the neighbouring tests already do.

**Fixed (with a worse twin).** It also assigned its 2-an-hour limit into the
module's `RATE_LIMIT_RULES` and never restored it, so every later test in a full
run inherited `public_read` at 2 an hour; `test_a_full_day_booking_closes_the_date_to_every_other_preset`
failed with a 429 in full runs only. Now `monkeypatch.setitem` and a `uuid4()` principal.
**Expect fewer "known" failures in full runs from here** - some of the baseline may have been this leak.

## DEPLOY CHECK: paid gigs without a settled base payment now release nothing

The download gate checks that the deposit was actually collected - a succeeded
`StripePayment` of `kind = base` - instead of trusting `gig.status`. Any gig
that is `paid`/`completed` with no such row will refuse to release finals.
That is correct for a real booking, and wrong for historical or seeded data
that was written without going through Stripe.

**Run before deploying**, against the target database. Gigs that have a
submitted selection are the only ones a client can be locked out of:

    SELECT g.id, g.status, g.created_at
    FROM gig g
    JOIN proof_gallery pg ON pg.gig_id = g.id
    JOIN client_selection cs ON cs.gallery_id = pg.id AND cs.status IN ('submitted', 'locked')
    WHERE NOT EXISTS (
        SELECT 1 FROM stripe_payment p
        WHERE p.gig_id = g.id AND p.kind = 'base' AND p.status = 'succeeded'
    );

Any row returned is a client who has chosen photos and would be refused them.
Fix those by writing the missing payment row (if money genuinely moved) or by
deciding the gig is fixture data. Not a code change.

**Local dev, 2026-09-19:** zero such rows. The 707 `completed` gigs are seeded
history (707 distinct clients, no payment rows, none with a gallery or a
submitted selection). Of the three gigs that have galleries, the end-to-end
one has a settled base payment; the other two are seed fixtures with nothing
submitted. One consequence: the fixed-id fixture `...0211` (`proofs_delivered`,
no payment) can no longer download finals, so a demo built on it needs a base
payment in the seed.

## PRIORITY: a short payment leaves the booking open and nothing tells the client

Same tier as the notification gaps above - a near-term product problem, not a
nice-to-have.

After the amount-received reconciliation, an underpayment leaves the booking
open with a real shortfall, and the selection quote correctly names it. But:

- nothing tells the client. There is no notification, no booking-status change
  and no banner; the booking simply does not complete;
- the selection screen starts empty on re-entry, because the server has no read
  for the current selection, so a client returning to finish paying is looking
  at a blank selection and the full quoted total, not "you owe EUR 1.00 more";
- the photographer sees an open booking with no explanation either.

Reaching this state needs a payment Stripe collected for less than we asked,
which the intent reconciliation is designed to prevent - so it should be rare,
and when it happens it will be silent. That combination (rare, money, silent)
is why it is in this tier rather than the backlog.

**What closes it:** a `payment_shortfall` next action on `GET
/v1/client/bookings/{id}` carrying the amount, a notification to the client on
the mismatch (the webhook already has both numbers), and a read for the current
draft selection so the screen can restore it. The first two are small.

## ~~Nobody could pass the gear gate, and the reader had never seen a real RAW~~ — FIXED

`activate_pro` had refused every photographer without verified gear since the
floor was added, and there was no way to become verified: `verify_from_raw` was
called only by tests and a seed script. Building the path turned up more than
the missing endpoint, because the reader behind it had only ever been tested
against JPEGs that Pillow made up. Run against **eight real camera files**
(CC0 samples from raw.pixls.us: Canon R5 and R, Sony A7 IV and A7 III, Nikon
Z6 and D850, Panasonic S5, Fujifilm X-T4) it failed in ways no synthetic test
could show:

| Found on real files | Effect |
| --- | --- |
| Canon **CR3** and Fujifilm **RAF** unreadable | 422 for every Canon body since 2018 and every Fuji |
| `details=False` turned maker notes off | the maker-note serial fallback could never fire; a Nikon D850's serial exists nowhere else |
| Nikon keeps the lens range in the maker note | a D850 reported no lens at all |
| Canon writes `0` for a lens's maximum aperture | `0 == 0` read a variable-aperture zoom as **fixed** and would have let it qualify |
| lighting ran through the EXIF reader | recorded the *camera's* lens model as the lighting's model; a wedding photographer could not satisfy the requirement |
| `MAX_UPLOAD_BYTES` is 25 MB | real RAWs are 16-58 MB; even a Sony A7 III file (25.6 MB) was over |
| the combined `/admin/pros/{id}/approve` checked no gear | see the category below |

**Fixed.** The reader unwraps CR3 (a Canon `uuid` box in `moov` holding three
TIFF streams) and RAF (a JPEG at the offset stored at byte 84), reads maker
notes, takes Nikon's maker-note range when the standard tag is absent, and
treats a maximum aperture of zero as *unknown*. Every one of these is pinned by
a test that uses header slices of the real files
(`tests/fixtures/raw/`, with provenance in its README), and each was broken
once to confirm the tests go red. Metadata fits in **under 64 KB** in every
format tried (a CR3's `moov` ends by 35 KB), so the server reads one megabyte
by ranged GET and never the other fifty.

**Intake.** A camera file goes up through the ordinary media flow with a new
`gear_evidence` purpose (no variants are made - a RAW cannot be decoded), and
`POST /v1/pro/me/gear-verifications` reads it. One file proves the body *and*
the lens it was shot on. Lighting is declared, as its own call, and stored as
`declared`. The reviewer's queue is `/admin/gear-verifications`; approving
provides what the machine could not (a body's sensor size, a lens's aperture
type), can add the model to the reference table so the next photographer with
that camera needs no review, and refuses to approve anything that would still
leave the floor unmet.

### Sony bodies publish no serial number, so every one goes to review

Read off the real files: neither Sony sample carries a body serial in any tag
exifread can read. Sony keeps it in encrypted maker-note data. Under the
existing (and deliberate) rule that a body with no serial cannot be claimed
exclusively and so needs a person, **every Sony body will be a queue item** -
and Sony is a large share of professional full-frame. Approving needs nothing
beyond a click (the model is in the reference table), so the cost is queue
volume, not photographer effort, and the photographer is told nothing is left
for them to do. The alternatives - decrypting Sony maker notes, or auto-verifying
serial-less known bodies and giving up exclusivity for them - are decisions, not
fixes, and are left as decisions.

Also worth knowing: exclusivity only proves a *serial* is unique, not that the
photographer owns the camera. EXIF is as easy to write into a RAW as into a
JPEG, so RAW raises the effort of faking, not the certainty. That is why
camera-original JPEGs are accepted too.

**Not done, and not to be assumed done:**

- **Not run on a device.** `file_picker` resolves and the flow is tested against
  a fake picker, but no iOS or Android build has picked a real file. The picker
  is unverified where it matters most.
- **Evidence is kept indefinitely.** Each verification leaves a 16-58 MB object
  in the bucket for as long as the row exists. That is deliberate (a decision
  can be re-examined) and has a storage cost that grows with photographers.
  No retention policy exists.
- **Other makers are untried.** Olympus/OM (ORF), Pentax, Leica DNG, Hasselblad
  and medium-format bodies were not sampled. TIFF-based ones should read;
  none is confirmed.

**Decision (2026-09-19): leave as is.** Approval is one click, the photographer is
told there is nothing for them to do, and routing a missing serial to review
rather than rejecting was already the design. Sony makes it visible, it does not
change the trade-off, and the rule is not worth weakening for a feature that has
not shipped. **If the review queue becomes a bottleneck at volume, this is why:**
each Sony body is one queue item. The levers, in the order to try them, are
batching approvals in the panel, then auto-verifying a known full-frame model
that publishes no serial (giving up exclusivity for those bodies only), and only
then decrypting Sony maker notes.

### The app threw away every deliberate 422 message

Found because an "unreadable file" reply showed the generic fallback. The
Flutter error mapper treated every HTTP 422 as FastAPI's own validation failure
(a `detail` array), so the backend's *deliberate* 422s - written with a message
for the person: unreadable file, unsupported type, oversize upload, blank
lighting model, and others across the API - all arrived as an empty validation
error with the message gone. Fixed in `error_mapper.dart` (an envelope-shaped
422 is now a `BusinessError`) with a test that fails without it. Every other
screen that surfaces a business error benefits.

**The fix caused two regressions, found by auditing every consumer.** Changing
what a deliberate 422 maps to is a behaviour change for anything that branched on
`Validation`, and nine places do. Reading each: six (auth, wallet, portfolio,
availability, pricing, profile) already handle `BusinessError(:message)` and now
show the specific sentence instead of a generic one - a real improvement. Two
had been relying on the old mapping and broke:

- **`cursor_page`**: the backend raises its bad-cursor error as a deliberate
  422, which used to hit the `Validation` branch ("drop the cursor, stop
  paging"). It stopped matching, so a bad cursor produced a retry button that
  resent the same value forever - the exact loop that branch exists to prevent.
- **`booking_request_controller`**: a deliberate 422 ("Invalid date window",
  "Invalid package") fell into the branch written for the 409, and told the
  client *"This photographer has not opened their calendar yet."*

Neither was caught by the existing tests. `cursor_page_test` builds
`Validation({})` by hand, so it never saw what the real mapper produces - a fake
standing where the real thing should be. Fixed by keeping the HTTP status on
`BusinessError` and adding `ApiFailure.isInvalidRequest` (FastAPI's own 422 *or*
a deliberate one), used at exactly the two sites that meant "the request was
invalid". The new tests feed the real backend response body through the real
mapper, and each piece of the fix was broken once to confirm they go red.

**Coverage, stated precisely.** The mapper test is general (it exercises
`mapDioException`, the one place every call passes through). What is verified
end to end is the two sites above plus the gear flow. The six improved consumers
are covered by the mapper test, not by a test of their own wording.

## CATEGORY: gates that say they enforce something and do not

Five instances now, found by different routes, all the same shape - a gate
whose documentation, commit message or name says it protects something, and
which does not, or cannot be passed. Worth treating as a category to look for,
not a run of bad luck.

1. **The tier price cap** enforced nothing: `niche_package_price_cap` had zero
   rows, so `enforce_entry_price_cap` returned on its first line.
2. **KYC approval** raised `NameError` on every call. The only gate between a
   photographer and going live had never worked.
3. **Finals downloads** for curve-priced bookings checked no payment. The commit
   that removed the upsell requirement said it would not strand photos, and
   never added the difference-payment requirement in its place.
4. **The gear floor on admin approval.** The commit introducing it said every
   approval enforced it. Only the older `/onboarding/pros/{id}/approve` did; the
   combined `/pros/{id}/approve` the review panel calls checked none of it, and
   the only approval tests were for the older route.
5. **The gear floor at activation** was enforced perfectly and could not be
   passed: nothing called the code that grants it.

The first four are gates that do not hold. The fifth is the mirror image, and
just as broken: a gate nobody can get through is enforced by nobody in practice,
because the first person who needs to go live gets it deleted.

**How to look for it.** For every gate: (a) a test that fails when the check is
deleted - written against the route the *product* calls, not a sibling that
happens to share a name; and (b) one journey that gets through it by the real
path, with no seed script and no hand-built row. Both were missing in every
case above.

## Photographers who went live before the gear gate — GRANDFATHERED, list on demand

The floor is enforced at activation and approval, so nothing already public was
re-checked. They stay live: they were listed before the requirement existed, and
making them re-verify would penalise them for a gap that was not theirs.

The cohort is derivable at any moment and needs no table: because nobody new can
be approved without gear, "publicly listed and gear floor not met" can only
contain people who were live when the gate arrived, and it shrinks as they
verify. `api/scripts/list_gear_grandfathered.py` prints it (read-only). **Dev,
2026-09-19: 44 listed, 44 without verified gear.**

Run it whenever the requirement changes - a new niche that needs lighting, a
stricter lens rule - to see who is affected before deciding whether to ask them
to verify. Deliberately not a table: that would be one more thing nothing reads,
and it would drift from the truth the moment someone verified.

## DEPLOY READINESS: production has no way to get the camera reference table or the price caps

Recorded with the same weight as the paid-gigs check, not folded into the gear
build. Both are *data* that behaviour depends on, and both arrive only by
running a script that the seed guard refuses to run in production.

- **`camera_model_reference`** (98 bodies in dev). With it empty, **every**
  submission routes to review, so gear verification technically works and
  automatically verifies nobody - the review queue becomes the whole intake.
  **Now loadable without the seed script:** admin → Catalog & pricing →
  Camera reference. "Download CSV" on a database that has the list, "Import
  CSV" on the one that does not; the import is checked row by row before
  anything is written and applies all or nothing. The page warns while no
  body is listed as full-frame. Importing does not re-decide submissions
  already waiting in the gear queue; those still need a person.
- **`niche_package_price_cap`** (40 of a possible 60 rows in dev). With it empty
  the entry-price ceiling enforces nothing (category item 1 above). **Now
  fillable from the admin:** the caps grid used to list only niches that
  already had a cap row, so on an empty table it listed nothing; it now shows
  every active niche, says when nothing is capped, imports and downloads a
  CSV, and the save endpoint refuses negative caps, a cap below its minimum
  and duplicates before writing anything.
- **`lens_model_reference`** (13 in dev) is the fallback for lenses whose file
  states no aperture; empty, those go to review. Still no admin page: only the
  seed script and the gear queue's "add to the reference list" box.

Neither is a migration, and `assert_environment_is_seedable` refuses production
by design, so a fresh production database starts with both empty and nothing
says so.

**Check before deploying**, against the target database:

    SELECT (SELECT count(*) FROM camera_model_reference) AS cameras,
           (SELECT count(*) FROM lens_model_reference)   AS lenses,
           (SELECT count(*) FROM niche_package_price_cap) AS price_caps;

**Proposed, not built:** a startup / health warning that names any of these
tables when it is empty, so the state is visible rather than discovered as
"why is everyone in the queue" or "why can a rookie price at master rates". The
reference data itself wants to be seed data loaded as part of a deploy (a data
migration, or a deploy-time script that is allowed to run in production), not a
developer command.

## ~~Any user could create a gig for any photographer, and a completed gallery could be re-opened~~ — FIXED

Four holes, all reproduced before anything was changed (the first row is worse
than the audit described it):

| Probe | Before |
| --- | --- |
| a user creates a gig for a photographer who **does not exist**, at EUR 0.01 | 200, `payment_pending` |
| the photographer creates a gallery for a **cancelled** gig, `included_photos: 999` | 200 |
| the photographer re-publishes a `selection_submitted` gallery | 200, gallery is `published` again |
| ...and the client then saves a new selection | 200 |
| a second publish | resets `published_at` |

**`POST /v1/gigs` was removed, not validated.** It had no caller anywhere
(`ENDPOINT_COVERAGE_AUDIT.md` recorded that, the web wrappers were unused, and
the Flutter helper was used only by its own test). Validating it would not have
been enough: even a correctly priced gig created through it commits a
photographer to a booking they never accepted. The three legitimate creators -
accept, confirm-slot, the legacy shoot - all carry the photographer's consent and
derive price from the package, so there was nothing to keep it for. The four
tests that used it as a fixture now build a gig row directly.

**The re-publish hole is Part 2's reselection lock reopened through the
photographer.** `save_selection` and `submit_selection` had been made to require
`published`, and `publish_gallery` set `published` unconditionally - so
re-publishing a completed booking's gallery undid it. Publish now works only from
`draft`; an already-published gallery is an idempotent no-op with none of the side
effects; anything else is a 409.

**Galleries.** A new gallery needs a deliverable booking (`paid`, or the legacy
`scheduled` / `shoot_done`; the rule lives in `gig_state.py` beside the state
machine). Returning an *existing* gallery stays unguarded, because the pro app
calls `create` to look at one. Adding photos needs a draft or published gallery on
a deliverable booking. The included-photo count and extras price come from the
gig's pricing snapshot, not the request body, so a photographer cannot type their
own extras price into a gallery; the body is used only where there is no usable
snapshot.

**The app.** The pro's gig card opens delivery only for statuses where it can
succeed (the "Active" filter includes unpaid gigs, whose cards used to lead to an
error screen). The classification is an exhaustive `switch`, so a status added on
the server has to be decided on rather than defaulting to openable.

## PRIORITY: two code paths build the same gig and have drifted apart

Found while reading the removal, deliberately not fixed in that change.
`accept_booking_request` (`pro_onboarding.py`) and
`_find_or_create_gig_from_booking` (`scheduling.py`) each construct a `Gig` from a
booking request and package, with the same derivation copied between them - and
they have already diverged: **the confirm-slot path writes no `pricing_snapshot`**
into the gig's metadata.

The consequences are concrete. The pro app builds a gallery's terms from that
snapshot and, finding none, falls back to `included_photos = 10` and
`extra_photo_price = "0.00"`. Until now the server also trusted whatever the
client sent; it now reads the snapshot when there is one, so for confirm-slot gigs
the fallback to the request body is what stands in. A booking created by
confirm-slot therefore records the amount and the entry rate but not the package
terms it was sold on (included photos, extras price, turnaround) - the record an
invoice or a dispute would reach for.

This is the same shape as the two pricing systems that double-billed extras and
the two chat route families: one thing built in two places, quietly drifting.
The fix is one shared builder that both call (and the legacy shoot's, which is a
third copy), with the snapshot written by the builder so no caller can forget it.
Worth doing as its own task with a test that builds a gig both ways and compares.

## ~~`test_followups_calls.py` fails between 22:00 and 08:00 Lisbon~~ — FIXED

Three tests (`test_calling_blocked_without_consent_except_call_me_button`,
`test_mock_telephony_flow_updates_status_and_outcome`, `test_rate_limits_enforced`)
grant a call to a contact whose quiet hours are 22:00-08:00 Europe/Lisbon and
never pin the clock, so they pass all day and fail at night with a 409
(`quiet_hours`). Found because a 32-minute full-suite run crossed midnight: the
same suite had passed in the afternoon, and three tests appeared as regressions
in a change that never touched call code.

Confirmed rather than assumed: on the real clock (00:08 Lisbon) four tests in the
file fail; with `is_quiet_hours_now` pinned to noon only the one known failure
(`test_transcript_not_stored_without_explicit_consent`) remains.

This is the second time-of-day test in this log (the scheduling fixture failed after
18:00 UTC). The practical consequence is for whoever compares runs: **a baseline
and a comparison taken either side of a quiet-hours boundary will show phantom
regressions in exactly this file.** Fix is to pin the clock in the tests, as the
notifications tests already do for their quiet-hours window.

**Fixed:** `tests/conftest.py` judges call quiet hours at midday Lisbon for every
test (`_quiet_hours_at_midday`). An explicit `now_utc` still wins, and a test
about quiet hours on the real clock marks itself `@pytest.mark.real_clock`.
`tests/test_test_clock.py` pins all three behaviours.

## The search screen is unreachable, and the router says otherwise - LOGGED

`DiscoverScreen` (`app/lib/features/client/discover/discover_screen.dart`) - the plain search-and-filter list, backed by `GET /v1/client/discover` - is not mounted on any route. Nothing constructs it outside its own file. The comment on the `/discover` route in `app_router_client.dart` says "Search still exists and is reachable from here"; it is not reachable from anywhere.

So a client has no way to search by name, filter by price, or see more than a row's twelve photographers. The niche pages cover browsing one niche; they do not replace search.

**Not fixed here.** Found while building the niche pages and kept out of that change. The fix is an entry point from the home screen (and correcting the comment), plus a decision on whether `/client/discover`'s niche filter should move off `top_niches` onto the membership rule the home rows use - it still has the top-three bug the home rows were fixed for.

## Niche tiles exist only on the home screen - LOGGED

`RNicheTile` has one caller: the heading of a niche row on the home screen. The niche-page design names three ways in - a tile, a row heading, a hero slide - and assumed tiles on a filter screen as well. There is no such screen with tiles (see above: the search screen has none and is not reachable).

The tiles that do exist are already live: a tile shows the first card's niche cover, which is the top-ranked photographer in that niche in the city. The app bundles no niche imagery at all (`assets/` holds only fonts), so there is nothing static to replace.

**Not fixed here.** Adding a row of niche tiles to search, when search gets an entry point, is its own small task. The niche page route (`ClientRoute.niche`) is what any new tile should open.

## Review tags exist in the model with no vocabulary, and nothing sends them - LOGGED

`Review.tags` is a JSONB list of free strings. `CreateReviewRequest` accepts any strings, `_normalize_tags` lowercases and dedupes them, and `recompute_pro_reputation` counts them into `ProReputation.tag_counts`. Nothing defines which tags exist, and no screen shows the counts.

The review form built for the client app sends no tags. Offering free text would fill `tag_counts` with one-off spellings; offering a fixed list would be inventing the vocabulary inside a UI task. Deciding the list (and whether clients or photographers ever see the counts) is a product decision that should come first; the form can then offer it as chips.

`video_media_asset_id` is in the same position: the model and create endpoint accept a Mux `video_review` asset, and there is no upload flow in either app to produce one.

## ~~The public review list said who wrote each review~~ — FIXED

`GET /v1/pros/{id}/reviews` needs no sign-in, and returned `client_user_id` and `gig_id` on every review, so anyone could link a client's account to a booking with a named photographer. It now returns `PublicReviewView`: rating, text, would-book-again, niche, date and reply, with no client and no booking. The app shows each review as a "Verified booking". Whether a reviewer's first name should ever be shown is a separate privacy decision, deliberately not made in the fix.

Alongside it, `GET /v1/client/bookings/{id}` now carries the client's own `review` (any status, including one a moderator hid; always null for the photographer), so the app can say "you reviewed this" without paging the public list.

## ~~Six places decided when a photographer could be booked, and no two agreed~~ — FIXED

The client's booking request refused only a window wholly inside blocked time, so it accepted 3am on a Sunday from a photographer who does not work Sundays, and any time inside their notice period. Accepting a request used the same lenient check. The chat / pro-side request path skipped notice and existing bookings. The pro's slot list read only the newer exceptions table, skipped the per-day cap, and missed a night shift that began the day before its range. Confirming a slot also skipped the deprecated blackouts. And nothing counted a paid gig as taking its time: accepting writes the gig's time without a `ConfirmedSlot`, so a paid shoot left its hour open to a second booking.

All six now go through `app/services/bookable_time.py`: notice, working hours (night shifts included), blocked time from both tables with any overlap, the per-day cap on the photographer's local day, and every existing booking - confirmed slots and paid gigs - with the policy's buffers. `tests/test_bookable_time.py` asks every entry point about the same time for each reason a time can be unbookable; removing the shared rule from any entry point, or any ingredient from the rule, fails it.

Behaviour that changed on purpose, for anyone reading old requests:

- A request is an exact time now, not a flexible window. `window_fully_blocked` and its "partial overlap is fine" premise are gone.
- The per-day cap counts the photographer's local day. It used to count UTC days, which disagree near midnight.
- A paid gig holds its time from payment, matching what the client app tells people.
- Fixed dates in March 2026 in four older tests only passed because nothing compared a requested time with "now"; they now ask for a time a few weeks ahead.

The public `GET /v1/pro/{id}/availability` is deleted. It needed no sign-in and returned every deprecated blackout's free-text `reason` - from the wrong table, in the wrong timezone - and nothing called it. Its replacement is `GET /v1/client/pros/{id}/availability`: signed in, live photographers only, open days and start times for one package, never why a day is closed.

## The pro's "available N of the next 14 days" still has its own rule - LOGGED

`_free_days_next_fortnight` (client_launch.py, behind the pro's listing preview) counts a day free unless blocked time covers it entirely. It ignores working hours, notice and existing bookings - the seventh copy of availability, found while unifying the other six and left alone because it is a display figure for the photographer, not a gate. It should become "days with at least one bookable start" from `bookable_starts`, so the number a photographer sees matches the calendar clients see.

## ~~Two clients could book and pay for the same hour~~ — FIXED

Reproduced, not theorised: two clients requested the same hour, the photographer accepted both, the calendar kept offering it, and both gigs were paid. Only paid gigs and confirmed slots held time; a pending request and an accepted-but-unpaid gig held nothing, nothing re-checked the hour when payment was taken, and unpaid gigs never expired.

Now (all in `app/services/bookable_time.py`, so every path agrees):

- A **pending request holds its hour** until it expires - first come, first served. It holds against requests made after it, not before: accepting a request is not blocked by later ones, so two overlapping requests left from before this change cannot deadlock each other.
- An **accepted, unpaid gig holds its hour for 24 hours** (`PAYMENT_WINDOW`, matching the photographer's reply window). Past that it holds nothing even before it is swept; the client app now says "we are holding this time for you for 24 hours".
- **Paying re-checks the hour** immediately before the PaymentIntent is created, ignoring the booking's own gig, and refuses after the 24 hours (`payment_window_closed`). Notice and working hours are not re-judged at payment - they were met when the booking was made.
- A **sweep** (`expire_unpaid_gigs`, every 15 minutes beside request expiry) cancels gigs unpaid after 24 hours. It cancels the Stripe PaymentIntent first and cancels the gig only if Stripe agrees; a payment already succeeding or in flight leaves the gig for the webhook to mark paid, so nobody is charged for a cancelled booking.
- The client calendar refetches after a request is sent or refused, on returning to the profile, and on pull-to-refresh.

Known edge left as it is: the webhook still moves a gig to paid without checking the hour. With the checks above a clash should not reach it, and refusing money Stripe has already taken is a refund flow, not a check.

## Scheduling presets: per-package layout of bookable times - BACKEND DONE, UI PENDING

Each package now has a `scheduling_preset` (`app/services/bookable_time.py`, `Shape`):

- `interval` - starts every `interval_minutes` through each working-hours window, anchored to the window's own start. No interval is the photographer's slot length: every existing package, unchanged (verified against the live calendar before and after the migration). 240 is the 4-hour preset; no other value is accepted.
- `blocks` - Morning / Afternoon / Evening at times the photographer sets per package (`package_session_block`). A block is offered only on a date whose working hours cover all of it. Booking one occupies the whole block.
- `full_day` - the whole local date. It occupies midnight to midnight, so the ordinary overlap check closes the date to every other booking and keeps a full day off any date with anything on it - including a night shift running past midnight. "Within working hours" means the photographer works that weekday; notice counts from that day's first working hour.

Buffers are owed between two bookings if either was made by the interval preset; two blocks sit against each other as the photographer drew them.

A request must be one of the windows its package offers (`check_offered`), on the client path and the chat / pro-side path - free time is not enough. A request records the preset it was made under (`booking_request.scheduling_preset`, carried into `gig.metadata`), and every later check judges it by that, not by the package's current setting.

Not covered here: the pro's own slot list (`/pro/scheduling/slots`) is per photographer, not per package, and stays on their slot length. A package's duration for a block or full-day preset is the shoot length shown to the client; the booking occupies the block or the date.

**Next:** the pro package editor needs a preset picker - nothing more for 4-hour or full day; three optional start/end pairs for blocks, with a warning when a block falls outside the photographer's working hours (it can never be offered). The client calendar needs to present blocks by name ("Morning · 06:00-11:00") and a full day as "Book this day", and to send each window exactly as offered (`start_at` / `end_at` from the calendar response).

## The calendar's offset test cannot tell Lisbon from UTC in winter - LOGGED

`test_a_night_shift_opens_the_small_hours_of_the_next_day` (`tests/test_bookable_time.py`)
checks that a calendar start carries the photographer's own offset. It picks its date
relative to today, three weeks out. It used to compare the string suffix against
`+00:00` / `+01:00`, which passed all summer and failed from the first date after the
clocks went back: Lisbon is UTC+0 in winter and pydantic writes a zero offset as `Z`.
It now compares the parsed offset with Lisbon's offset on that date.

The gap that remains: **from late October to late March the test is run with Lisbon
and UTC at the same offset, so it cannot catch a calendar that drops the
photographer's zone and answers in UTC.** It passes either way in those months. Only
a summer run proves the offset is carried. Anyone changing timezone handling in
`bookable_time.py` or the calendar serialiser during winter should not read a green
run as coverage of this. Fix is to pin the test to a fixed summer date (or add a
second case for one) instead of a date relative to today.

## Review moderation: "hidden" and "removed" are the same thing, and nobody is told - LOGGED

Found while building the admin Reviews page. Every reader of `review.status`
(public list, reputation, niche skills, proof of gigs) checks `== published`,
so `hidden` and `removed` have identical effects: off the profile, out of the
rating. The page says so in its dialogs rather than implying a difference. If
the two are meant to differ (e.g. hidden = pending a decision, removed = final
and not restorable), that is a product decision nobody has made.

Recommendation when deciding (product owner, 2026-10-04): "hidden" should mean
reversible / under review and "removed" final. Decide before it is
load-bearing - the first time a photographer disputes a moderation decision,
the distinction will matter and the system cannot currently express it.

Moderating sends no notification. The photographer's rating changes without
explanation, and a client whose review disappears is not told why - they find
out only if they look at their booking, which still shows it. Both need a
decision on wording before anything is sent.

Fixed alongside: `POST /admin/reviews/{id}/moderate` accepted no reason, and a
repeat of the same decision was logged and recomputed again. It now requires a
reason and answers a repeat with 409.

## CATEGORY: a decision is made and the person it affects is never told

The same gap, logged separately at least four times, wearing different hats:

1. **A booking request arrives** and the photographer learns of it only by
   opening the app - against a 48-hour auto-decline (the notification delivery
   entry above: no mail provider, push not built at all).
2. **A short payment** leaves the booking open and nothing tells the client
   (PRIORITY entry above).
3. **A selection difference** is quoted, and nothing tells the client.
4. **A review is moderated**: the photographer's rating changes and the client's
   review disappears, and neither is told (review moderation entry above).

Treat it as the signal, not four features. Notification delivery is the thing
underneath all of them; when it is built it should be built **once,
generically** - an outward channel (email, push) behind `enqueue_notification`,
with per-event wording - and then plugged into each of these, rather than
solved per feature. Until then, each new "nobody is told" belongs on this list.

## Edge caching for portfolio images: blocked on a bucket decision - NOT BUILT

Approved in principle (public portfolio derivatives only), stopped on discovery.
An R2 custom domain - the only way Cloudflare's edge caches R2 objects - exposes
the **whole bucket**, not chosen objects. Every presigned URL the apps have ever
been handed carries the object key in its path, including finals (10-minute
links), proofs and gear RAWs. With a custom domain on this bucket, anyone who
ever held such a link could fetch the same object from the custom domain
forever, unsigned - which would quietly undo the payment gate.

Safe ways to do it, both configuration rather than code, and both a product
call: (a) a separate public bucket holding only portfolio thumbnails, written
there by the derivative task; or (b) a Cloudflare rule on the custom domain that
refuses every path outside a dedicated `public/` prefix, with portfolio
thumbnails written under it. Either way, originals and anything gated stay on
signed URLs. Until then, repeat views are served from the phone's disk cache
(stable URLs + `DiskCachedImage`), which needs no exposure at all.

## Upload resume survives a dropped connection, not a killed app - LOGGED

Large uploads go to R2 in 5 MiB parts and resume from the last finished part
(verified on real R2: a 25.6 MB Sony RAW, three connection failures, arrived
byte-identical). The resume state lives in the upload call, so it covers a
dropped or flaky connection during one app session. If the app is killed
mid-upload the next attempt starts a new asset; the abandoned multipart upload
is aborted only if the app gave up cleanly. Persisting resume state on the
device (asset id, which parts arrived) is a separate task, as agreed. R2 also
needs a lifecycle rule to expire incomplete multipart uploads - configuration,
worth adding with that task.

## deploy/docker-compose.{prod,staging}.yml are stale duplicates - LOGGED

The deploy workflow uses `deploy/compose.prod.yml` and `compose.staging.yml`.
The `docker-compose.*` pair beside them are older copies (the prod one has no
beat service at all). Not changed with the worker split, so they are now further
out of date; deleting them is the clean fix.

## Transfer timings in this repo's speed work describe one slow link - NOTE

The 2026-10-05 measurements ran over a connection doing ~165 KB/s down and
10-80 KB/s up (measured against Cloudflare's own speed test at the time). CPU
numbers and request counts are environment-independent; transfer times are not,
and production's worker-to-R2 link was not measurable from here.

## ~~`test_blackout_blocks_accepting_a_booking_inside_it` fails late in the evening~~ — FIXED

The test gives its photographer working hours of 00:00-23:59 every day and asks
for a 3-hour booking starting `now + 32 days`. Run after about 21:00, that
window runs past midnight, crosses the 23:59 end of the rule, and is refused as
"outside working hours" before the blackout check it exists to test is ever
reached. Found in a 2026-10-06 overnight run; the same test on the same tree
passed at 06:34. Fix is to pin the requested start to midday, as the quiet-hours
entry above recommends for its tests.

**Fixed:** the file's bookings start at 10:00 UTC on the target day
(`_days_ahead_at_ten`) instead of at the current time of day, so no booking in it
can cross midnight whatever hour the suite runs. A pin on the test clock would
have hidden the dependence; removing it is the fix.

## iOS suspension unverified on a physical device - LOGGED

Presence (the online dot) rests on two behaviours of the pro app: it stops
heartbeating and sends one clear when it goes to the background, and when no
clear arrives - force-quit, crash, no signal - the server's presence key
expires after `PRESENCE_WINDOW_SECONDS` (5 minutes) and the dot goes with it.

Verified:

- the expiry on real Redis, with the window shortened to 2 seconds: one
  heartbeat, no clear, and the dot is gone from home and the profile (test);
- the default of 300 (guard test);
- the app lifecycle driving the heartbeat: away stops it with exactly one
  clear, back restarts it, a quick flick through inactive drops nothing
  (widget test);
- a failing or hanging server: no crash, never reported as online, backoff
  10s/20s/40s capped at the minute, recovery on the first success (fake
  client);
- on two iOS simulators (pro app on an iPhone 16e, client view watched
  through the API every 2s), 2026-10-12:
  - launch 23:17:24 -> heartbeat 23:17:33.0 -> shown online 23:17:35;
  - backgrounded by launching Settings 23:17:48 -> one clear 23:17:58.98 ->
    offline;
  - relaunched 23:18:24 -> online 23:18:29;
  - force-quit with `xcrun simctl terminate` 23:18:33 -> no clear sent -> key
    expired by Redis and dot gone 23:23:28, 300s after the last heartbeat.

Not verified: how a real iPhone suspends the app. A simulator delivers the
lifecycle events promptly and keeps the network up; a phone may suspend
before the clear is sent, or in airplane mode cannot send it at all. The
five-minute expiry is designed to cover exactly that, but it has only been
observed on simulators. A device check is on the deploy checklist's
blocks-real-client-launch list.

## ~~Admin tier overrides were undone by the next recompute~~ — FIXED

An admin's tier override was written into the skill's `breakdown` under
`admin_override`; the recompute read only `override` (which nothing wrote) and
then replaced `breakdown` wholesale. Within the hysteresis window the tier
happened to stick; after it, the next recompute of any kind - a review, an
accepted booking, a rebuild-all - put the evidence tier back. Proven on
2026-10-12 (elite back to rookie). The old record also sat where the
photographer's own view of their tier showed it in full: the admin's id and
note.

**Fixed (migration 0059):** an override is a set of columns - tier, and
optionally score and verified, with who set it, when and why - read by every
recompute as the effective value until an admin removes it. `evidence_tier`
keeps what the evidence alone says beside it; the admin page shows the two and
says when they disagree. Set and remove are both audited. Hysteresis damps only
the evidence, and now holds any evidence change within the cooldown of the last
one in either direction - which is also what
`test_hysteresis_blocks_rapid_promotion_flip` always expected, so it passes. The
photographer sees only that an override is active. Rebuild-all reports how many
overrides it preserved. Overrides already erased before 0059 cannot be
recovered from the row; the deploy checklist lists them from the event log.

## ~~A photographer's primary niche could change on any recompute~~ — FIXED

Top niches were sorted by tier, score, rating and gigs, and a photographer's
unworked niches tie at zero on all four. Ties came out in the order Postgres
returned the rows, which on larger tables is their physical order and moves
whenever a row is rewritten - so the first of the tied niches, which becomes the
primary niche (the niche row a photographer is guaranteed a place in), could
change on any recompute. A second rebuild-all on dev changed 58 rows.

**Fixed:** ties go to the niche the photographer chose as their primary, then by
niche id (`niche_skills.order_niches`, tested on rows fed in reverse, because a
small test database happens to return them in id order already).

## Seeded demo tiers were not supported by the tier rules — HANDLED

`seed_fake_photographers.py` wrote tiers straight into the tier column; the tier
rules require verification for skilled and above, which the seeded photographers
do not have, so the first full recompute demoted 32 of them on dev. The seed now
sets its tiers through the override path with the reason "demo seed": they
survive recomputes and show on the admin page as overrides that disagree with
the evidence - which, for invented photographers, they do.

## Available now: what changed beyond the toggle - LOGGED

Short-notice booking (`app/services/available_now.py`, `deadlines.py`) brought four changes worth knowing about outside it.

- **Accepting and confirming a slot judge notice by the request's own terms - for the time it asked for.** A request records, when made, whether it was short notice and the notice it was made under. Accept, and confirm-slot at the requested time, ask "was this bookable when it was requested?" (notice counted from `created_at`) rather than "is it bookable now?". Confirming any *other* time, whether a different window or a reschedule, is judged as a new request made now (see the next entry). Without that, a short-notice request could not be accepted once the toggle went off, and an ordinary request made 25 hours ahead could not be accepted two hours later. Working hours, blocked time, other bookings, holds and the daily limit are still judged now. The effect on ordinary requests is to relax a refusal that was a false one.
- **The pay deadline is recorded on the gig** (`pay_deadline_at`), and the hold, the pay route, the unpaid sweep and the client's screens all read it. It replaced three separate 24-hour constants. Gigs from before it fall back to `created_at` + 24 hours.
- **Accepting is refused (`too_late_to_pay`) when the pay deadline - capped `PAY_DEADLINE_MARGIN_MINUTES` before the start - has already passed.** That only happens when a short-notice request is answered very close to the shoot.
- **The photographer skills endpoints (`/v1/pro/me/skills`, `/v1/pros/{id}/skills`) had no test.** When `niche_id` became required in their shared view, both would have returned 500. Both now set it, and a test covers both.

**Sweeps: correctness does not wait for them.** An unanswered request is refused on accept and confirm-slot from its `expires_at`, and stops holding its time from then. An unpaid booking is refused on payment and stops holding from its pay deadline. The sweeps only change the status the lists show. They now run every 60 seconds (`BOOKING_REQUEST_EXPIRY_SWEEP_INTERVAL_SECONDS`, was 900). Each holds a Postgres advisory lock for its transaction, so a run that overlaps the previous one skips. A run with nothing due is one indexed query: the request sweep has a partial index on pending requests' deadlines (migration `20261014_0062`), and the unpaid sweep uses `ix_gig_status`.

**Preparation time is 1.5, 2, 3, 4 or 6 hours, and payment closes 30 minutes before the shoot.** 90 minutes is the floor, not a preference. A request at the edge of the notice may be accepted up to 30 minutes later, and must then leave 30 minutes to pay before the 30-minute margin. A test checks that every offered option keeps the whole pay window when accepted at the last moment, and another shows 60 minutes would not.

**Client availability is not cached.** It is computed per request, so switching on or off shows on the client's next calendar load (`test_the_calendar_is_never_served_stale_across_a_toggle`).

**`make test-isolated` run from a worktree's own `api/` reports "all 15 Redis indexes are claimed".** That message is false: compose there finds no `.env` and no running Redis, so the claim command fails, and the script reads any non-OK reply as "claimed". Run it from the main `api/` with `REPO=<worktree>`, as documented.

## ~~Confirm-slot judged a reschedule by the original request's notice~~ - FIXED

Found while listing the routes no test called (2026-10-13). Available now made confirm-slot judge notice from when the request was made, which is right for the time the client asked for. But confirm-slot also places a *rescheduled* time, and that was judged the same way: a booking requested a week ago, against 24 hours' notice, could be moved to three hours from now (proven with a throwaway test: 200).

Now the recorded terms apply only to the exact requested time. Any other time is judged as a new request made now: notice counted from now, the toggle, the package flag and the app's freshness as they are now, the package's offered windows, and every other client's hold. The gig's pay deadline is worked out again for the new time, and confirming is refused (`too_late_to_pay`) when that deadline has already passed. The request's own terms are left as they were, still describing the time it asked for. Tests and break checks: `tests/test_available_now.py` (confirming a time other than the one requested) and `tests/test_scheduling_routes.py` (reschedule-request, cancel-slot, the scheduling policy), which no test had called before.

## `PUT /v1/pro/scheduling/policy` replaces the whole policy - LOGGED

Every field of `SchedulingPolicyUpdateRequest` has a default, and the route writes all of them. So a body carrying only `advance_notice_hours` silently resets the buffers, slot length and daily limit to their defaults. Clients must send the whole policy. `test_a_put_replaces_the_whole_policy` records this behaviour so a change to it is deliberate. A partial-update `PATCH`, or `exclude_unset`, would be the fix, but nothing in the apps sends a partial body today.

## ~~The app's integration test left an account in dev on every run~~ - FIXED

`integration_auth_flow_test.dart` registers an `f5-<n>@rawwers.test` photographer. It ran on every plain `flutter test` that found a backend on localhost:8000, so whenever the dev stack was up it left one account behind: 97 by 2026-10-13. Now:
- the `integration` tag is skipped by default (`dart_test.yaml`), and the tests run only on request: `flutter test --tags integration --run-skipped`
- before any test they check that the backend they call (the app's own `API_BASE_URL`) is on this machine and reports a development or test environment through `/v1/dev/environment`, and fail every test otherwise
- the test deletes its account at the end through `DELETE /v1/dev/test-accounts/me`

Both dev routes exist only when `APP_ENV` is development, dev, local or test. Elsewhere they answer 404 before authentication, and they are not in the published API. The deletion refuses anything but an `@rawwers.test` account made in the last hour with no booking or money rows. The 91 existing f5 accounts were de-listed on 2026-10-13 (never visible to clients); nothing deleted them.

## Discover's live rows: "Available now" and "Online now" - LOGGED

Both rows lead Discover and every niche page. They are worked out on every request, after the cached rows (`app/services/live_rows.py`), from the primary database rather than the replica, so a photographer who switches off or goes quiet is gone on the next request.

- **Online now:** presence fresh (the dot's five minutes) and the dot visible. A photographer who hides the dot is left out.
- **Available now:** switched on, presence fresh (two minutes), an active short-notice package (in the niche, on a niche page), and a real bookable start in the next 24 hours from `bookable_windows`, the rule every booking path uses.

**Order never uses ranking.** "Available now" sorts by preparation time, then a rotation; "Online now" by the rotation alone. The rotation is a hash of the day, the viewer and the photographer.

**Cost per home request:** one indexed query for the eligible photographers, one presence MGET that also sets every card's dot, one query for who is switched on, and the availability rule for at most `AVAILABLE_CANDIDATE_CAP` (24) candidates. Dev Lisbon, 2026-10-14: 15 eligible, 3 checked, 36-66 ms warm (431 ms on the first, cold request). Almost all of it is the availability rule, about 10-20 ms per candidate warm, so a city with 24 switched-on photographers would add roughly half a second.

**Failure.** If Redis cannot answer, both rows are left out and the dots go too; if anything else in them fails, the rows are left out and the dots fall back to their own lookup. The screen never fails for them.

**Freshness, the toggle and the package flag are checked twice.** `live_rows` filters on them before the availability rule, as a cheap pre-filter. The rule enforces them anyway: a stale, switched-off or unflagged photographer gets ordinary notice, and so has no start in the next 24 hours. Tests check both: the photographer is left out, and the expensive check is never run for them.

**The app** fetches Discover again when it comes back into view (app resumed, Discover tab selected, a profile or niche page popped), at most every 15 seconds (`discover_freshness.dart`). Cards show "Ready in about N hours" while the server says the photographer is available now.
