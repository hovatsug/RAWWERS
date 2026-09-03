/// PublicAvailabilityResponse
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "rules": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/app__schemas__onboarding__AvailabilityRuleView"
///             },
///             "title": "Rules"
///         },
///         "blackouts": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/BlackoutView"
///             },
///             "title": "Blackouts"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "rules",
///         "blackouts"
///     ],
///     "title": "PublicAvailabilityResponse"
/// }
library public_availability_response;

import 'exports.dart';
part 'public_availability_response.freezed.dart';
part 'public_availability_response.g.dart'; // PublicAvailabilityResponse

@freezed
abstract class PublicAvailabilityResponse with _$PublicAvailabilityResponse {
  const PublicAvailabilityResponse._();

  @jsonSerializable
  const factory PublicAvailabilityResponse({
    /// proUserId
    @JsonKey(name: PublicAvailabilityResponse.proUserIdKey_)
    required String proUserId,

    /// rules
    @JsonKey(name: PublicAvailabilityResponse.rulesKey_)
    required List<AvailabilityRuleView> rules,

    /// blackouts
    @JsonKey(name: PublicAvailabilityResponse.blackoutsKey_)
    required List<BlackoutView> blackouts,
  }) = _PublicAvailabilityResponse;

  factory PublicAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$PublicAvailabilityResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String rulesKey_ = r'rules';

  static const String blackoutsKey_ = r'blackouts';
}
