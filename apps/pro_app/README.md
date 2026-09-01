# RAWWERS Pro App

This package reuses the existing Flutter foundation in `flutter/`.

- Core Dio client and auth refresh: `flutter/lib/data/api/*`
- Pro adapter: `flutter/lib/core/api/pro_api.dart`
- Compatibility export: `apps/pro_app/lib/core/api/pro_api.dart`

Run the existing Flutter app:

```bash
cd flutter
flutter pub get
flutter run
```

Current Pro screens live in `flutter/lib/features/pro_*` and `flutter/lib/features/pros/*`.
