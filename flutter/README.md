# RAWWERS Flutter Foundation Slice #33

This folder provides the Flutter mirror foundation for web slice #32 with shared tokens, app shell, routing, API wiring, and core mirrored components.

## What is included

- Riverpod baseline state architecture.
- GoRouter app shell with role-aware bottom navigation and guarded routes.
- Dio API client with:
  - auth header interceptor
  - 401 refresh with single-flight behavior
  - safe logging (no request/response bodies or auth headers)
  - backend error mapping with `request_id` passthrough when provided
- Secure token strategy:
  - access token in memory (`TokenStore`)
  - refresh token in secure storage (`flutter_secure_storage`)
- Feature flag loading (`/v1/feature-flags`) with app-resume refresh.
- Screens:
  - Login / Register / Verify Email / Reset Password
  - Discover (`/v1/client/discover`)
  - Pro profile read-only (`/v1/client/pros/{id}`)
  - Notifications (`/v1/me/notifications`)
  - Pro onboarding checklist read-only (`/v1/pro/onboarding/checks`)

## Project structure

- `lib/app`: app root, shell, router
- `lib/design`: generated tokens/theme and mirrored design widgets
- `lib/data`: API, models, repositories
- `lib/features`: feature providers + screens
- `tool/generate_tokens.dart`: token generation
- `test/`: component/widget tests

## Token regeneration

Source of truth:

- `../web/design-system/tokens.json`

Regenerate Flutter token/theme files:

```bash
cd flutter
dart run tool/generate_tokens.dart
```

Generated outputs:

- `lib/design/tokens.dart`
- `lib/design/theme.dart`

## Component mapping (Web -> Flutter)

- `Button` -> `RButton` (`primary`, `secondary`, `ghost`)
- `Card` -> `RCard`
- `Input` -> `RTextField`
- `BottomSheet` -> `showRBottomSheet(...)`
- `Tabs` -> `RTabs`
- `Badge` -> `RBadge`
- `Skeleton` -> `RSkeleton`

## Routing and guards

Primary routes:

- `/login`
- `/register`
- `/verify-email`
- `/reset-password`
- `/discover`
- `/pros/:id`
- `/notifications`
- `/pro/onboarding`

Guard rules:

- unauthenticated users are redirected to `/login` for protected routes
- authenticated users are redirected away from auth screens
- `/pro/onboarding` requires `pro` role

## Deep links

`go_router` path routing supports incoming deep links for mirrored routes (`/pros/:id`, `/verify-email`, etc.).
Configure native platform URL intents/associated domains in Android/iOS project configs when platform folders are generated.

## Setup

```bash
cd flutter
flutter pub get
flutter test
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Optional location defaults for discovery:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=DEFAULT_COUNTRY=US \
  --dart-define=DEFAULT_CITY=New\ York
```
