import 'package:rawwers/api/models/notification_preference_update.dart';
import 'package:rawwers/api/models/notification_preference_view.dart';

/// `PUT /v1/me/notification-preferences` only overwrites fields that are
/// non-null in the request body - a partial update despite the PUT verb.
/// Building a request with only the edited fields would silently wipe the
/// rest of the user's notification preferences.
///
/// Always build from the full current preferences, then `.copyWith(...)`
/// just the fields being edited:
///
/// ```dart
/// final request = buildNotificationPreferenceUpdateRequest(current).copyWith(digestMode: newMode);
/// ```
NotificationPreferenceUpdate buildNotificationPreferenceUpdateRequest(
  NotificationPreferenceView current,
) {
  return NotificationPreferenceUpdate(
    timezone: current.timezone,
    quietHoursEnabled: current.quietHoursEnabled,
    quietStartLocal: current.quietStartLocal,
    quietEndLocal: current.quietEndLocal,
    channelEmailEnabled: current.channelEmailEnabled,
    channelInappEnabled: current.channelInappEnabled,
    digestMode: current.digestMode,
  );
}
