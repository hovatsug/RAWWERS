# RAWWERS — Flutter apps

One Flutter project, two flavors: **client** (`RAWWERS`) and **pro** (`RAWWERS Pro`). No web/desktop targets — iOS and Android only.

## Structure

```
lib/
  core/
    router/          go_router setup
    env.dart          --dart-define-from-file values
    flavor.dart        which flavor is running
    api/               transport layer (F-3): Session/SessionStorage, Result<T>/ApiFailure,
                        error_mapper, auth+refresh interceptors, dio_client, debug logging
    api_wrappers/       structural full-state wrappers for partial-update PUTs (F-2)
    money/              typed Decimal wrappers for the API's dynamic money fields (F-3)
    upload/             presigned-PUT photo upload orchestration (F-3)
  api/               generated OpenAPI client (F-2) — never hand-edited
  design/
    tokens.dart          color/type/spacing/radii/elevation - the only place a hex or size literal should exist
    typography.dart       shared type-scale builder
    theme_client.dart      dark ThemeData
    theme_pro.dart          light ThemeData
    components/            RButton, RInput, RCard, RStatusChip, RSkeleton, REmptyState,
                            RErrorState, RImageTile, RProgressBar, showRConfirmDialog, showRSheet
    gallery/                debug-only widget gallery (not routed from either app yet - F-5 wires an entry point)
  features/
    shared/          used by both flavors
    client/          client-only — must never be imported by main_pro.dart
    pro/             pro-only — must never be imported by main_client.dart
  main_client.dart
  main_pro.dart
tool/
  check_flavor_isolation.dart   enforces the client/pro import boundary above
  filter_openapi.dart           F-2's tag/path-prefix OpenAPI filter
env/
  client.example.json / pro.example.json   committed templates
  client.json / pro.json                   gitignored, your local values
```

## Setup

```
cp env/client.example.json env/client.json
cp env/pro.example.json env/pro.json
# edit env/*.json to point at your local API, if not http://localhost:8000
flutter pub get
```

## Run

```
flutter run --flavor client -t lib/main_client.dart --dart-define-from-file=env/client.json
flutter run --flavor pro -t lib/main_pro.dart --dart-define-from-file=env/pro.json
```

## Codegen

Riverpod providers use `@riverpod` (riverpod_generator) exclusively — no manually written `Provider`/`StateNotifierProvider` syntax. After adding or changing one:

```
dart run build_runner build --delete-conflicting-outputs
```

Generated `*.g.dart` files are committed.

**Riverpod is pinned to 2.6.1** (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) — deliberately, not just "not yet updated." The latest `riverpod_annotation` (4.x) has no `riverpod_generator` release that resolves against this Flutter SDK's pinned `meta`/Dart version (`flutter pub add` fails version solving). Don't bump these past `2.6.1` without first confirming a compatible `riverpod_generator` exists for the Flutter version in use.

## Flavor isolation

`features/client/` and `features/pro/` must never import from each other — enforced, not just conventional:

```
dart run tool/check_flavor_isolation.dart
```

Runs in CI on every push.

## iOS flavor setup

Two schemes (`client`, `pro`), each with its own build configurations (`Debug-client`/`Release-client`/`Profile-client` and the `-pro` equivalents), each layering `ios/Flutter/Client.xcconfig` or `Pro.xcconfig` on top of the standard Flutter xcconfigs to set `PRODUCT_BUNDLE_IDENTIFIER`, `PRODUCT_NAME`, and `FLUTTER_TARGET`. Bundle IDs: `com.rawwers.client` / `com.rawwers.pro`.

## Android flavor setup

Product flavors `client` / `pro` in `android/app/build.gradle.kts`, same bundle-id split via `applicationId`, app label via a per-flavor `resValue`.

**If an Android build fails with a bare version number as the error** (e.g. `* What went wrong: 25.0.3`, no other detail), that's not a flavor problem — it's Gradle failing to even start against a too-new JDK. A freshly installed Android Studio can bundle a JBR ahead of what your pinned Gradle wrapper supports (this repo's `gradle-wrapper.properties` is on Gradle 8.14, which tops out around JDK 24; AGP itself isn't validated past JDK 21/partial 24 as of writing — see [flutter/flutter#187223](https://github.com/flutter/flutter/issues/187223)). Fix: install a JDK 17 or 21 (`brew install openjdk@17`) and point Flutter at it — `flutter config --jdk-dir=$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home` — rather than bumping Gradle/AGP to chase the newest JDK.

## Money is decimal-string end to end, never a double

The backend serializes every money field (`*_eur`, package `price`/`extra_photo_price`, etc.) as a pattern-constrained JSON string, specifically to avoid float-precision bugs. The generated API client mirrors that: money fields come out as `String`, not `num`/`double`. **Never parse them into a `double` for arithmetic** — a client-side total computed as `double` can silently drift from the backend's figure by a cent, and on this app that's a real charge. Any place the app computes a total itself (the selection gallery's live running total is the only one at MVP) must use a decimal-safe type (the `decimal` package) for that arithmetic, converting to/from the wire string only at the boundary.

A few request bodies (`ProPackageCreateRequest.price`/`extra_photo_price`, `ProPackageUpdateRequest`'s equivalents, `PayoutRequestCreateRequest.amount_eur`, `CreateGigRequest.amount_total`) accept either a number or a string on the way in, so the generator types them as `dynamic` with no safety at all. **Build these requests only through `lib/core/money/`** (`createProPackageRequest`/`applyProPackagePriceEdits`, `createPayoutRequest`, `createGigRequest`) — every one of those functions takes a `Decimal`, never a raw generated constructor call, and serializes with `.toStringAsFixed(2)` (not `Decimal.toString()`, which strips trailing zeros — `150.00` would come out as `"150"`).

## Transport layer (F-3)

Every generated `*Client` call is wrapped through `lib/core/api/api_call.dart`'s `apiCall()`, which returns a `Result<T>` (`lib/core/api/result.dart`) — `Ok(value)` or `Err(ApiFailure)` — instead of throwing. Nothing crosses the API boundary as an exception. `ApiFailure` (`lib/core/api/api_failure.dart`) is a sealed class matched via exhaustive `switch`: `Unauthorized`, `Forbidden`, `NotFound`, `Validation(fieldErrors)`, `RateLimited`, `BusinessError(code, message)`, `ServerError(message)`, `NetworkError`, `Timeout`.

`error_mapper.dart` maps a real `DioException` to one of those, built against the backend's two actual error shapes (verified against the live API, not assumed): FastAPI/Pydantic's own 422s are unwrapped (`{"detail": [{"loc","msg"}]}`), everything else goes through the app's custom `{"error": {"code","message"}}` envelope. `BusinessError` isn't in the original spec's fixed list — added because arbitrary 4xx business-rule rejections (duplicate email, niche cap exceeded, etc.) carry a real `code`/`message` in that envelope that the UI needs, and dropping them into `ServerError` would misrepresent a 4xx as an infra failure.

**Session** (`lib/core/api/session.dart`): `SessionStorage` (real impl: `SecureSessionStorage`, backed by `flutter_secure_storage`) reads/writes the access+refresh token pair as **one record, one write** — never two separate writes. `/v1/auth/refresh` rotates both tokens together; if they were written separately, an access-token write succeeding while the refresh-token write fails would permanently strand the session (holding a refresh token the backend has already invalidated).

**Single-flight 401 refresh** (`lib/core/api/auth_interceptors.dart`): `AuthInterceptor` attaches the current access token to every request; `RefreshInterceptor` catches 401s and de-dupes concurrent refreshes via a single `Future<bool>?` in flight — every 401 arriving while a refresh is already running awaits that *same* refresh instead of starting a new one. This is a correctness requirement, not an optimization: rotation means a second concurrent refresh (using the now-stale token the first one just rotated away) would be rejected by the backend. `test/core/api/refresh_interceptor_test.dart` fires 5 concurrent 401s and asserts exactly one call to `/v1/auth/refresh`, all 5 originals succeeding on retry, and exactly one `SessionStorage.write`.

**Uploads** (`lib/core/upload/photo_upload_service.dart`): this API has no multipart endpoints — media goes to R2 via a 3-step presigned-PUT flow (`POST .../uploads` → PUT the bytes → `POST .../complete`). A failed PUT is retried by going back to step 1 for a *fresh* presigned URL, never by re-PUTing the same one (they expire, and a stale retry 403s). `complete` is called at most once and is **never** auto-retried, even though it isn't a payment/booking/gig — checked against the real handler, it 409s if called again after a success the client failed to observe, so it isn't actually idempotent. `test/core/upload/photo_upload_service_test.dart` fails 2 PUTs before succeeding and asserts 3 distinct presigned URLs were used and `complete` was called exactly once.

No generic retry-on-network-error exists for arbitrary requests. The only two retry paths are the two above (401-then-retry-once, which is always safe because a 401 is rejected before the handler runs — nothing was created — and upload-retry-from-step-1, bounded and scoped to a non-mutating PUT). A POST that creates a payment, booking request, or gig is never retried automatically by this transport.

Debug-only logging (`debug_log_interceptor.dart`) logs method/URL/status only — never request or response bodies, which is the simplest way to guarantee a token buried in a login/refresh payload never reaches the log — and redacts the `Authorization` header value.

`test/core/api/integration_transport_test.dart` is tagged `integration` (see `dart_test.yaml`) and makes one real call through the full stack against the local backend (`docker compose up` in `api/`). CI excludes it (`flutter test --exclude-tags=integration`) since that job has no live backend; run it locally with `flutter test --tags=integration`.

## Design system (F-4)

Tokens only, in `lib/design/tokens.dart` — no color or size literal should exist anywhere else. Both themes (`theme_client.dart` dark, `theme_pro.dart` light) build from the same tokens; the divergence is functional, not aesthetic — client is browsed at night making a purchase decision, pro is used outdoors in daylight glare.

**Color**: four named scales. `RInk` is the neutral scale (backgrounds/text/borders, both themes). `RAccent.meter500` (`#4A7FA5`, a light-meter-dial blue) is the one accent — same hex in both apps, deliberately, as a cross-app consistency signal most apps don't bother with. It's cool on purpose: an earlier warm red-orange draft was rejected specifically because warm accent chrome shifts perceived skin tones next to photographs, which is exactly what this app's users are most sensitive to. `RAccent.meter700` is a separate, darker shade used only for button fills, so button label text clears AA contrast — `meter500` itself can't guarantee that at text sizes (see the contrast note below). `RDevelop.develop500` (muted moss) and `RShade.shade600` (muted slate) are booking-state colors, not generic success-green/error-red.

**The booking flow's 15 states collapse to 3 chip treatments** (`RStatusChip`, `RStatusChipKind`) — the state name carries the specific meaning; color only says ongoing (`inProgress`, plain outline), done (`positive`, `develop500` outline), or broken (`stopped`, `shade600` **filled** — the one chip kind that's filled, not outlined, because `CANCELLED`/`DISPUTED` are the two states a photographer must notice immediately).

**Contrast**: given how close to pure black/white `RInk.i950`/`i050` are, ~4.29:1 is the theoretical ceiling for any single hex against both simultaneously (worked out from the WCAG relative-luminance formula) — no accent choice clears 4.5:1 (AA normal text) on both at once, only 3:1 (AA for large text/UI components/graphical objects). `RAccent.meter500` sits close to that ceiling; buttons route through the darker `meter700` fill instead of relying on it directly, and `RTextLink` always underlines rather than depending on color alone for body-sized links. `test/design/contrast_test.dart` computes the real WCAG formula against the actual tokens and asserts each of these — a regression guard against a future token edit silently dropping a pairing below AA.

**Type**: one family only, **Archivo** (`assets/fonts/`, OFL-licensed, variable font — weights are selected via `FontVariation('wght', …)`, see `RType`, not separate font files per weight). Substituted for the original plan's General Sans, which is Fontshare-exclusive with no reliable way to fetch/bundle it here; same intent (single grotesk, no display/body pairing — chrome doesn't compete with the photos, so it doesn't get a second, more expressive typeface). Every number in a data-table-like context uses `RType.tabularFigures` (the `tnum` OpenType feature) so digits stay column-aligned.

**Radii/elevation**: sharp corners (`RRadius.photo = 0`) on photo content specifically — photography is rectangular (prints, negatives, contact sheets) — with slightly-rounded chrome elsewhere and no stadium/pill shapes anywhere. Elevation is border-based (a 1px hairline) almost everywhere; `RElevation.shadowFloat` is the one shadow, reserved for genuinely floating surfaces (sheets, dialogs, the eventual pinned selection-gallery total bar).

**Quality floor**: `test/design/widget_gallery_test.dart` renders every token/component in both themes, at both an iPhone SE-sized and a large-phone viewport, at both 1.0x and 1.3x text scale (dynamic type), and with the OS reduced-motion flag set, asserting no overflow/exceptions in any combination. `test/design/touch_target_test.dart` asserts `RButton`/`RTextLink` meet the 44pt minimum (`rMinTouchTarget`).

The gallery screen (`RWidgetGalleryScreen`) isn't routed from either app's real navigation yet — F-5 wires a debug-only entry point to it, gated by `kDebugMode`.

## App shells + auth (F-5)

**Session state** is a two-variant sealed class (`lib/core/auth/auth_state.dart`): `AuthUnauthenticated` and `AuthAuthenticated(me)`. There is deliberately **no third "unknown/checking" variant** — `AuthController.build()` *is* the check (read session storage, then `GET /v1/me`), so it only ever returns a resolved value, and the window while it runs is exactly Riverpod's own `AsyncLoading<AuthState>`. A custom `AuthUnknown` was written first and deleted: nothing would ever have set it, and the router would have had a dead branch matching on it forever.

`AuthController` is **`keepAlive`, not auto-dispose** — this is the session, and it must outlive any particular listener. Under auto-dispose, a momentary gap in listeners (a route transition, a plain non-widget `read`) tears the controller down and silently re-runs `build()`, firing a fresh `GET /v1/me` and discarding whatever `login()` or `upgradeToPro()` had just set. Both routers happen to hold it alive today, which hid this entirely in the running apps; it surfaced only under the integration test, where nothing was watching. That's an accident of wiring, not a guarantee, so the lifetime is now stated explicitly.

**Silent refresh on launch costs nothing extra.** `build()` just calls `GET /v1/me` through the normal transport — if the stored access token is stale, F-3's `RefreshInterceptor` handles the 401, single-flight refresh, and retry transparently underneath. There is no separate launch-time refresh path to keep in sync with the request-time one.

**Register returns no tokens.** Checked against the real handler (`api/app/api/v1/auth.py`), `POST /v1/auth/register` returns a bare success payload, not a token pair — so `register()` always follows with a real `login()` using the same credentials. Shipping the assumed shape would have produced a confusing double-login. That follow-up call is also why a successful registration writes the session exactly once, which the integration test asserts.

That two-step introduces a **split failure**: register succeeds, the follow-up login doesn't, and the account now exists. Routing back to the register form would have the user retry straight into "email already exists", so `register()` instead moves state to `AuthUnauthenticated(message: 'Your account was created. Log in to continue.')` and the router lands them on Login. The message rides on the state rather than a one-off navigation argument, so the screen shows it however the user got there.

**Roles.** Every account registers as `client` — the backend adds that role unconditionally and `pro` is only ever granted by the idempotent `POST /v1/me/upgrade-to-pro`. So the pro app's upgrade gate is the *common path* for a new photographer, not an error case, and `UpgradeToProScreen` reads as onboarding rather than a permission denial: one line each on entering at a tier that reflects work already done, working new niches without touching your own brand, and earnings converting toward gear. Email verification is *not* a gate — no backend dependency requires `email_verified_at` — so `VerifyEmailScreen` is reachable from Account/Settings whenever, never forced into the signup path.

**Launch screen.** `/launch` renders a real splash (`lib/core/launch/launch_screen.dart`) for the `AsyncLoading` window. On a slow connection the gap between reading storage and `/v1/me` resolving is visible, and the alternative is a flash of the login screen at users who are in fact already signed in.

**Navigation** is one system per app — `StatefulShellRoute.indexedStack`, four tabs, no sidebar. Client: Discover / Bookings / Messages / Account. Pro: Today / Requests / Gigs / Wallet, with settings reached from a header avatar button rather than spent as a fifth tab. Route paths are named constants (`ClientRoute`, `ProRoute`), so a typo is a compile error at the call site, not a runtime 404. Each app's `redirect` owns its own definition of "authenticated enough" — the pro router additionally requires the `pro` role and diverts to the upgrade screen — which is why `AuthState` itself stays flavor-agnostic.

**Account enumeration**: the forgot-password screen always reports success, including when the API call fails. Confirming whether an address exists is a real leak, and it isn't worth a marginally better error message.

**A generated-client bug had to be fixed first.** Any endpoint whose OpenAPI response is a free-form object (`additionalProperties: true` with no `properties` — FastAPI's bare `-> dict`) makes swagger_to_dart emit `dynamic.fromJson(...)`, which isn't valid Dart. Nothing had imported `AuthClient` before F-5, so this had sat uncompiled since F-2; 7 occurrences across 5 client files. Note that *avoiding the call* doesn't help — Dart compiles every method body in an imported class, so the file fails to build whether or not you invoke the broken method. Since `lib/api/` is generated and never hand-edited, the fix is `tool/fix_generated_client_bugs.dart`, a deterministic idempotent post-processing step wired into `make gen-api` after `build_runner`; the correct value is just the already-decoded body (`_value = _result.data!`). A one-off hand-patch would have been silently reverted by the next regeneration.

**Tests**: `test/core/auth/integration_auth_flow_test.dart` (tagged `integration`, needs the local backend) drives the whole deliverable against the real API — register, auto-login, client-only roles, upgrade to pro, roles added not replaced, logout clearing stored session — plus a wrong-password path asserting the user-facing string isn't a raw exception and that nothing is written. The two boot tests (`main_client_test.dart`, `main_pro_test.dart`) override `sessionStorageProvider` with the in-memory fake, since the real `SecureSessionStorage` has no platform-channel handler under `flutter test`, and use bounded `pump()` calls rather than `pumpAndSettle()` — the launch screen's spinner never settles on its own.

## Pro app core (F-6)

The four pro tabs — Today, Requests, Gigs, Wallet — built against real endpoints. Three of them did not exist before this task: the API only had fetch-by-id for booking requests, gigs and client bookings, so no client could enumerate a photographer's work queue. Those routes were added backend-side (`b91ee8ba`) and are documented in `docs/BACKEND_GAPS.md`.

**Paging is shared, not per-screen.** Every list endpoint returns `{items, next_cursor}`, so `lib/core/paging/` holds the shape once: `CursorPage` for state, `appendNextPage` for the transition, `PagedListView` for loading/error/empty/load-more. Two behaviours worth knowing. A failed *append* keeps the rows already on screen with a retry beneath them, rather than replacing a loaded list with a full-screen error because page three timed out. And a `Validation` failure **drops the cursor and stops** — the backend now rejects an unparseable cursor with a 422 instead of silently restarting, so retrying the same stale value would loop forever.

**The countdown is server-seeded and server-resolved.** `BookingRequestListItem.secondsUntilExpiry` is a duration, not a timestamp, precisely so a device with a skewed clock can't misreport the one deadline the product enforces; only elapsed time is measured locally. When it reaches zero the screen **refetches** rather than rendering "expired" — the backend's expiry sweep runs every 15 minutes, so between the deadline passing and the sweep running the request is still acceptable. Rendering a closed door that is in fact open would cost a photographer the booking.

**Accepting requires approved KYC.** A new pro is `unsubmitted`; `submit-kyc` only moves them to `pending`, and approval is admin-only with no admin UI in either app. So every photographer hits the `409 kyc_required` gate on their first request — it's the normal path, not an exception, and reads as onboarding rather than an error. Locally, `ALLOW_UNVERIFIED_PRO=true` in `api/.env` bypasses it (dev-gated in the backend, not a client-side flag).

**Gig states**: the backend's 15 `GigStatus` values map to F-4's three chip treatments in `gig_status_display.dart` — feature code owns that mapping, since the design system deliberately doesn't know domain state names. Labels are written from the pro's side ("You've been paid", "Client selecting"), and a test asserts every enum value has both a label and a kind, so a status added server-side can't silently render as "in progress". The Gigs tab's three grouped filters partition all 15 exhaustively (also asserted) — the API filters by a single status, so grouping is applied client-side while `nextCursor` stays the server's, and paging still walks the whole list.

**Today** bounds "today" to the device's local midnight, sent as UTC instants — a 09:00 Lisbon shoot should not land on the wrong day because the backend reasons in UTC. Pending requests appear as a count pointing at the Requests tab, never a second copy of the list: two places to accept from is two places to keep in sync.

**Wallet** shows all five balance buckets, not just the withdrawable figure — showing one would make earnings look like they vanished between a shoot and a payout. The **€50 minimum and 2-requests-per-7-days** rules are mirrored from `api/app/services/payouts.py` and enforced before submit rather than surfaced as a 422; the server stays the authority and a rejection is still handled, this only avoids making someone find the floor by hitting it. Payout account is **status only** — bank details are the most sensitive input in the app and Stripe Connect onboarding is a hosted flow, not a form, so entry is its own task. The earnings ledger is labelled "most recent" because that endpoint takes a `limit` with no cursor: there is no honest way to page it, and a fake infinite scroll would be worse than saying so.

**Autofill**: `RInput` takes `autofillHints`, and both auth forms sit in an `AutofillGroup`. Leaving hints off does not mean "no autofill" — iOS guesses from surrounding labels, and was observed offering the device's Apple ID into the sign-up email field. The register/login split matters specifically: `newPassword` prompts the OS to offer to *save*, `password` prompts it to *fill*.

**Two design-system additions**, both token-based and covered by the gallery's overflow / text-scale / reduced-motion matrix: `RButtonVariant.secondary` (an outlined action offered alongside a primary one — Decline is deliberately not red, since declining is a normal outcome of reviewing a request, not a destructive one) and `RFilterChip` (kept separate from `RStatusChip` so status colours can't leak onto a control, where they'd read as state rather than selection).

**A second generator-bug variant** surfaced here. Adding a `ProOnboardingClient` provider pulled `GET /v1/niches` into compilation for the first time; its `list[dict]` response generates `Map<String, dynamic>.fromJson(...)`, which does not exist — same class of bug as F-5's `dynamic.fromJson`, same mechanism (Dart compiles every method body in an imported class, so a latent break surfaces the moment anything imports the client). `tool/fix_generated_client_bugs.dart` now handles both shapes **and exits non-zero if any unfixed `.fromJson` remains**, so the next variant fails at generation time pointing at the script, rather than as a confusing compile error weeks later. Note that a bare `dart run build_runner build` does not apply these fixes — use `make gen-api`.

Since `lib/api/**` is excluded from analysis, generated-code breakage does not appear in `flutter analyze`; it surfaces at compile time via `flutter test` or a build. That is the intended trade (281 unactionable infos were burying real warnings), and this bug is the worked example of it failing loudly enough.

**Tests**: each screen is rendered against fixture data with its controller overridden (`test/features/pro/`), asserting what actually reaches the screen — countdown present only while pending, actions absent on a settled request, an error never reading as "you have none", grouped filters hiding the right gigs, payout rules stated before submit. This is the verification the simulator could not give: AppleScript reaches the iOS springboard but not the Flutter canvas, so these tabs cannot be driven by hand there. Interactive tap-through on a real device remains unverified.
