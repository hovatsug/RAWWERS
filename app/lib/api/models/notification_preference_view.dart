/// NotificationPreferenceView
/// {
///     "properties": {
///         "timezone": {
///             "type": "string",
///             "title": "Timezone"
///         },
///         "quiet_hours_enabled": {
///             "type": "boolean",
///             "title": "Quiet Hours Enabled"
///         },
///         "quiet_start_local": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Quiet Start Local"
///         },
///         "quiet_end_local": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Quiet End Local"
///         },
///         "channel_email_enabled": {
///             "type": "boolean",
///             "title": "Channel Email Enabled"
///         },
///         "channel_inapp_enabled": {
///             "type": "boolean",
///             "title": "Channel Inapp Enabled"
///         },
///         "digest_mode": {
///             "$ref": "#/components/schemas/NotificationDigestMode"
///         }
///     },
///     "type": "object",
///     "required": [
///         "timezone",
///         "quiet_hours_enabled",
///         "channel_email_enabled",
///         "channel_inapp_enabled",
///         "digest_mode"
///     ],
///     "title": "NotificationPreferenceView"
/// }
library notification_preference_view;

import 'exports.dart';
part 'notification_preference_view.freezed.dart';
part 'notification_preference_view.g.dart'; // NotificationPreferenceView

@freezed
abstract class NotificationPreferenceView with _$NotificationPreferenceView {
  const NotificationPreferenceView._();

  @jsonSerializable
  const factory NotificationPreferenceView({
    /// timezone
    @JsonKey(name: NotificationPreferenceView.timezoneKey_)
    required String timezone,

    /// quietHoursEnabled
    @JsonKey(name: NotificationPreferenceView.quietHoursEnabledKey_)
    required bool quietHoursEnabled,

    /// quietStartLocal
    @JsonKey(name: NotificationPreferenceView.quietStartLocalKey_)
    String? quietStartLocal,

    /// quietEndLocal
    @JsonKey(name: NotificationPreferenceView.quietEndLocalKey_)
    String? quietEndLocal,

    /// channelEmailEnabled
    @JsonKey(name: NotificationPreferenceView.channelEmailEnabledKey_)
    required bool channelEmailEnabled,

    /// channelInappEnabled
    @JsonKey(name: NotificationPreferenceView.channelInappEnabledKey_)
    required bool channelInappEnabled,

    /// digestMode
    @JsonKey(name: NotificationPreferenceView.digestModeKey_)
    required NotificationDigestMode digestMode,
  }) = _NotificationPreferenceView;

  factory NotificationPreferenceView.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceViewFromJson(json);

  static const String timezoneKey_ = r'timezone';

  static const String quietHoursEnabledKey_ = r'quiet_hours_enabled';

  static const String quietStartLocalKey_ = r'quiet_start_local';

  static const String quietEndLocalKey_ = r'quiet_end_local';

  static const String channelEmailEnabledKey_ = r'channel_email_enabled';

  static const String channelInappEnabledKey_ = r'channel_inapp_enabled';

  static const String digestModeKey_ = r'digest_mode';
}
