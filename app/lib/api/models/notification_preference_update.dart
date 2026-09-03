/// NotificationPreferenceUpdate
/// {
///     "properties": {
///         "timezone": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Timezone"
///         },
///         "quiet_hours_enabled": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
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
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Channel Email Enabled"
///         },
///         "channel_inapp_enabled": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Channel Inapp Enabled"
///         },
///         "digest_mode": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/NotificationDigestMode"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "title": "NotificationPreferenceUpdate"
/// }
library notification_preference_update;

import 'exports.dart';
part 'notification_preference_update.freezed.dart';
part 'notification_preference_update.g.dart'; // NotificationPreferenceUpdate

@freezed
abstract class NotificationPreferenceUpdate
    with _$NotificationPreferenceUpdate {
  const NotificationPreferenceUpdate._();

  @jsonSerializable
  const factory NotificationPreferenceUpdate({
    /// timezone
    @JsonKey(name: NotificationPreferenceUpdate.timezoneKey_) String? timezone,

    /// quietHoursEnabled
    @JsonKey(name: NotificationPreferenceUpdate.quietHoursEnabledKey_)
    bool? quietHoursEnabled,

    /// quietStartLocal
    @JsonKey(name: NotificationPreferenceUpdate.quietStartLocalKey_)
    String? quietStartLocal,

    /// quietEndLocal
    @JsonKey(name: NotificationPreferenceUpdate.quietEndLocalKey_)
    String? quietEndLocal,

    /// channelEmailEnabled
    @JsonKey(name: NotificationPreferenceUpdate.channelEmailEnabledKey_)
    bool? channelEmailEnabled,

    /// channelInappEnabled
    @JsonKey(name: NotificationPreferenceUpdate.channelInappEnabledKey_)
    bool? channelInappEnabled,

    /// digestMode
    @JsonKey(name: NotificationPreferenceUpdate.digestModeKey_)
    NotificationDigestMode? digestMode,
  }) = _NotificationPreferenceUpdate;

  factory NotificationPreferenceUpdate.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferenceUpdateFromJson(json);

  static const String timezoneKey_ = r'timezone';

  static const String quietHoursEnabledKey_ = r'quiet_hours_enabled';

  static const String quietStartLocalKey_ = r'quiet_start_local';

  static const String quietEndLocalKey_ = r'quiet_end_local';

  static const String channelEmailEnabledKey_ = r'channel_email_enabled';

  static const String channelInappEnabledKey_ = r'channel_inapp_enabled';

  static const String digestModeKey_ = r'digest_mode';
}
