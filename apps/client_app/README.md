# RAWWERS Client App

This app currently reuses the existing Flutter implementation under `flutter/`.

## API adapter
- `flutter/lib/core/api/client_api.dart`
- Compatibility export: `apps/client_app/lib/core/api/client_api.dart`

## Flavors / entrypoints
- Client app:
```bash
cd flutter
flutter run -t lib/main_client.dart --dart-define=APP_FLAVOR=client --dart-define=API_BASE_URL=https://app.rawwers.com
```
- Pro app:
```bash
flutter run -t lib/main_pro.dart --dart-define=APP_FLAVOR=pro --dart-define=API_BASE_URL=https://app.rawwers.com
```
