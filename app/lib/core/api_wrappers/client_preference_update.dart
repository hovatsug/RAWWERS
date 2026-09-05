import 'package:rawwers/api/models/client_preference_update_request.dart';
import 'package:rawwers/api/models/client_preference_view.dart';

/// `PUT /v1/me/client-preference` overwrites the whole record - the handler
/// assigns every field from the body (`row.location = body.location or {}`
/// and so on), so anything omitted is reset, not left alone. Sending only the
/// edited field would wipe the client's niches, budget, style tags and
/// consent default.
///
/// Always build from the full current preference, then `.copyWith(...)` just
/// what is being changed:
///
/// ```dart
/// final request = buildClientPreferenceUpdateRequest(current)
///     .copyWith(location: {'country': 'PT', 'city': 'Lisbon'});
/// ```
///
/// `budgetMin`/`budgetMax` are money and the generated request types them as
/// `dynamic`, so they are carried straight through here rather than being
/// parsed - passing an existing value along untouched cannot introduce a
/// float-precision error, whereas round-tripping it through a `double`
/// could. Anything that actually *edits* a budget must go through
/// `lib/core/money/` and hand a `Decimal` in.
ClientPreferenceUpdateRequest buildClientPreferenceUpdateRequest(
  ClientPreferenceView current,
) {
  return ClientPreferenceUpdateRequest(
    preferredNiches: current.preferredNiches,
    budgetMin: current.budgetMin,
    budgetMax: current.budgetMax,
    styleTags: current.styleTags,
    location: current.location,
    consentDefault: current.consentDefault,
  );
}
