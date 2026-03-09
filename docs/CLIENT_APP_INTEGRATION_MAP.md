# CLIENT App Integration Map

## Existing Flutter foundation reused
- Dio stack:
  - `flutter/lib/data/api/client.dart`
  - auth refresh interceptors in `flutter/lib/data/api/interceptors.dart`
- Auth state:
  - `flutter/lib/features/auth/providers.dart`
  - session model: `flutter/lib/data/models/session.dart`
- Routing shell:
  - `flutter/lib/app/router.dart`
  - `flutter/lib/app/app_shell.dart`
- Existing client feature slices:
  - `flutter/lib/features/discover/*`
  - `flutter/lib/features/notifications/*`
  - `flutter/lib/features/pros/*` (public pro profile/listing card view)

## Client adapter added
- `flutter/lib/core/api/client_api.dart`
  - `ClientApiResult<T>` + `ClientApiFailure`
  - Methods for auth, discovery, bookings, gigs, proofs, disputes, preferences, rewards, prints, referrals.
- Provider:
  - `flutter/lib/core/api/client_api_provider.dart`

## Compatibility export
- `apps/client_app/lib/core/api/client_api.dart`

## Safe extension rules
1. Add endpoint wrappers in `ClientApi` first.
2. UI should consume adapters/providers; no raw dio URL calls in widgets.
3. Keep auth/refresh only in interceptors and auth controller.

## Missing/constraints observed
- Booking list endpoint mismatch between legacy screens and provided catalog; use locally tracked booking IDs + `GET /v1/client/bookings/{booking_id}`.
- Some gallery pricing fields may vary by response; render safe fallback labels when absent.
