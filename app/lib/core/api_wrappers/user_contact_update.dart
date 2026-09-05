import 'package:rawwers/api/models/user_contact_update_request.dart';
import 'package:rawwers/api/models/user_contact_view.dart';

/// `PUT /v1/me/contact` only overwrites fields that are non-null in the
/// request body - a partial update despite the PUT verb. Building a
/// request with only the edited fields would silently wipe the rest of
/// the user's contact info.
///
/// Always build from the full current contact, then `.copyWith(...)` just
/// the fields being edited:
///
/// ```dart
/// final request = buildUserContactUpdateRequest(current).copyWith(phoneE164: newPhone);
/// ```
UserContactUpdateRequest buildUserContactUpdateRequest(UserContactView current) {
  return UserContactUpdateRequest(
    phoneE164: current.phoneE164,
    timezone: current.timezone,
    quietHoursStart: current.quietHoursStart,
    quietHoursEnd: current.quietHoursEnd,
  );
}
