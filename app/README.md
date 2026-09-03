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
  design/            design system (F-4)
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
