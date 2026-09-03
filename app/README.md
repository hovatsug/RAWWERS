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
