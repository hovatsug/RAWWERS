import 'package:rawwers/api/models/pro_profile_update_request.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';

/// `PUT /v1/pro/me/profile` only overwrites fields that are non-null in the
/// request body - a partial update despite the PUT verb. The generated
/// [ProProfileUpdateRequest] always sends every optional field explicitly
/// (including null), so building one from scratch with only the edited
/// fields would silently wipe everything else on the pro's profile.
///
/// Always build from the full current profile, then `.copyWith(...)` just
/// the fields being edited:
///
/// ```dart
/// final request = buildProProfileUpdateRequest(current).copyWith(displayName: newName);
/// ```
ProProfileUpdateRequest buildProProfileUpdateRequest(ProProfileView current) {
  return ProProfileUpdateRequest(
    displayName: current.displayName,
    headline: current.headline,
    coverMediaAssetId: current.coverMediaAssetId,
    bio: current.bio,
    city: current.city,
    country: current.country,
    languages: current.languages,
    styles: current.styles,
    gear: current.gear,
  );
}
