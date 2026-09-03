/// UserContactView
/// {
///     "properties": {
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "phone_e164": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Phone E164"
///         },
///         "timezone": {
///             "type": "string",
///             "title": "Timezone"
///         },
///         "quiet_hours_start": {
///             "type": "string",
///             "format": "time",
///             "title": "Quiet Hours Start"
///         },
///         "quiet_hours_end": {
///             "type": "string",
///             "format": "time",
///             "title": "Quiet Hours End"
///         }
///     },
///     "type": "object",
///     "required": [
///         "user_id",
///         "timezone",
///         "quiet_hours_start",
///         "quiet_hours_end"
///     ],
///     "title": "UserContactView"
/// }
library user_contact_view;

import 'exports.dart';
part 'user_contact_view.freezed.dart';
part 'user_contact_view.g.dart'; // UserContactView

@freezed
abstract class UserContactView with _$UserContactView {
  const UserContactView._();

  @jsonSerializable
  const factory UserContactView({
    /// userId
    @JsonKey(name: UserContactView.userIdKey_) required String userId,

    /// phoneE164
    @JsonKey(name: UserContactView.phoneE164Key_) String? phoneE164,

    /// timezone
    @JsonKey(name: UserContactView.timezoneKey_) required String timezone,

    /// quietHoursStart
    @JsonKey(name: UserContactView.quietHoursStartKey_)
    required String quietHoursStart,

    /// quietHoursEnd
    @JsonKey(name: UserContactView.quietHoursEndKey_)
    required String quietHoursEnd,
  }) = _UserContactView;

  factory UserContactView.fromJson(Map<String, dynamic> json) =>
      _$UserContactViewFromJson(json);

  static const String userIdKey_ = r'user_id';

  static const String phoneE164Key_ = r'phone_e164';

  static const String timezoneKey_ = r'timezone';

  static const String quietHoursStartKey_ = r'quiet_hours_start';

  static const String quietHoursEndKey_ = r'quiet_hours_end';
}
