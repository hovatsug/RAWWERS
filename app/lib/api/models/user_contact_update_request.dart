/// UserContactUpdateRequest
/// {
///     "properties": {
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
///         "quiet_hours_start": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Quiet Hours Start"
///         },
///         "quiet_hours_end": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Quiet Hours End"
///         }
///     },
///     "type": "object",
///     "title": "UserContactUpdateRequest"
/// }
library user_contact_update_request;

import 'exports.dart';
part 'user_contact_update_request.freezed.dart';
part 'user_contact_update_request.g.dart'; // UserContactUpdateRequest

@freezed
abstract class UserContactUpdateRequest with _$UserContactUpdateRequest {
  const UserContactUpdateRequest._();

  @jsonSerializable
  const factory UserContactUpdateRequest({
    /// phoneE164
    @JsonKey(name: UserContactUpdateRequest.phoneE164Key_) String? phoneE164,

    /// timezone
    @JsonKey(name: UserContactUpdateRequest.timezoneKey_) String? timezone,

    /// quietHoursStart
    @JsonKey(name: UserContactUpdateRequest.quietHoursStartKey_)
    String? quietHoursStart,

    /// quietHoursEnd
    @JsonKey(name: UserContactUpdateRequest.quietHoursEndKey_)
    String? quietHoursEnd,
  }) = _UserContactUpdateRequest;

  factory UserContactUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserContactUpdateRequestFromJson(json);

  static const String phoneE164Key_ = r'phone_e164';

  static const String timezoneKey_ = r'timezone';

  static const String quietHoursStartKey_ = r'quiet_hours_start';

  static const String quietHoursEndKey_ = r'quiet_hours_end';
}
