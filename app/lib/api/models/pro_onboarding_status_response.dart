/// ProOnboardingStatusResponse
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ProOnboardingStatus"
///         },
///         "current_city": {
///             "anyOf": [
///                 {
///                     "type": "object"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Current City"
///         },
///         "invite_code_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Invite Code Id"
///         },
///         "notes": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Notes"
///         },
///         "started_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Started At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "status",
///         "started_at",
///         "updated_at"
///     ],
///     "title": "ProOnboardingStatusResponse"
/// }
library pro_onboarding_status_response;

import 'exports.dart';
part 'pro_onboarding_status_response.freezed.dart';
part 'pro_onboarding_status_response.g.dart'; // ProOnboardingStatusResponse

@freezed
abstract class ProOnboardingStatusResponse with _$ProOnboardingStatusResponse {
  const ProOnboardingStatusResponse._();

  @jsonSerializable
  const factory ProOnboardingStatusResponse({
    /// proUserId
    @JsonKey(name: ProOnboardingStatusResponse.proUserIdKey_)
    required String proUserId,

    /// status
    @JsonKey(name: ProOnboardingStatusResponse.statusKey_)
    required ProOnboardingStatus status,

    /// currentCity
    @JsonKey(name: ProOnboardingStatusResponse.currentCityKey_)
    Map<String, dynamic>? currentCity,

    /// inviteCodeId
    @JsonKey(name: ProOnboardingStatusResponse.inviteCodeIdKey_)
    String? inviteCodeId,

    /// notes
    @JsonKey(name: ProOnboardingStatusResponse.notesKey_) String? notes,

    /// startedAt
    @JsonKey(name: ProOnboardingStatusResponse.startedAtKey_)
    required DateTime startedAt,

    /// updatedAt
    @JsonKey(name: ProOnboardingStatusResponse.updatedAtKey_)
    required DateTime updatedAt,
  }) = _ProOnboardingStatusResponse;

  factory ProOnboardingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ProOnboardingStatusResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String statusKey_ = r'status';

  static const String currentCityKey_ = r'current_city';

  static const String inviteCodeIdKey_ = r'invite_code_id';

  static const String notesKey_ = r'notes';

  static const String startedAtKey_ = r'started_at';

  static const String updatedAtKey_ = r'updated_at';
}
