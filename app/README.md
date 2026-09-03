# RAWWERS — Flutter apps

One Flutter project, two flavors: **client** (`RAWWERS`) and **pro** (`RAWWERS Pro`). No web/desktop targets — iOS and Android only.

## Structure

```
lib/
  core/              shared infra: router, env, flavor
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

The backend serializes every money field (`*_eur`, package `price`/`extra_photo_price`, etc.) as a pattern-constrained JSON string, specifically to avoid float-precision bugs. The generated API client mirrors that: money fields come out as `String`, not `num`/`double`. **Never parse them into a `double` for arithmetic** — a client-side total computed as `double` can silently drift from the backend's figure by a cent, and on this app that's a real charge. Any place the app computes a total itself (the selection gallery's live running total is the only one at MVP) must use a decimal-safe type (e.g. the `decimal` package) for that arithmetic, converting to/from the wire string only at the boundary.

A few request bodies (`ProPackageCreateRequest.price`/`extra_photo_price`, `PayoutRequestCreateRequest.amount_eur`, `CreateGigRequest.amount_total`) accept either a number or a string on the way in — the generator can't type these safely (see F-3's hand-written wrappers around exactly these fields). Feature code must go through those wrappers, never the raw generated field, so a value can't accidentally get sent as a `double`.
