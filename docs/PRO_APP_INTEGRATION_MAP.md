# PRO App Integration Map

## Existing Flutter foundation reused
- Dio client + auth refresh:
  - `flutter/lib/data/api/client.dart`
  - `flutter/lib/data/api/interceptors.dart`
- Token storage:
  - `flutter/lib/data/api/token_store.dart`
- Auth repository:
  - `flutter/lib/data/repositories/auth_repository.dart`
- Routing:
  - `flutter/lib/app/router.dart` (GoRouter with auth/pro guards)
- Existing Pro feature modules:
  - `flutter/lib/features/pro_onboarding/*`
  - `flutter/lib/features/pros/*`

## New adapter added
- `flutter/lib/core/api/pro_api.dart`
  - Unified `ProApiResult<T>` and `ProApiFailure`
  - All requested pro-domain methods routed through existing Dio stack
- Provider:
  - `flutter/lib/core/api/pro_api_provider.dart`
- Compatibility export:
  - `apps/pro_app/lib/core/api/pro_api.dart`

## How to add endpoints safely
1. Add methods only in `ProApi` (or repository wrappers that use `apiDioProvider`).
2. Do not call raw URLs directly inside widgets.
3. Keep auth/session logic in existing interceptors and token store.
4. Always return `ProApiResult` for predictable UI error handling.

## Where to place glue code
- State providers: `flutter/lib/features/<feature>/providers.dart`
- UI screens: `flutter/lib/features/<feature>/*_screen.dart`
- Shared widgets/tokens: `flutter/lib/design/*`

## Missing / constraints
- Catalog lacks pro booking-request list and gig list endpoints; use thread + id-driven flows.
- Some listing-card fields are derived views; persist only supported underlying resources.
