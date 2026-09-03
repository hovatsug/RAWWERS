/// AvailabilityRulesResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/app__schemas__scheduling__AvailabilityRuleView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "AvailabilityRulesResponse"
/// }
library availability_rules_response;

import 'exports.dart';
part 'availability_rules_response.freezed.dart';
part 'availability_rules_response.g.dart'; // AvailabilityRulesResponse

@freezed
abstract class AvailabilityRulesResponse with _$AvailabilityRulesResponse {
  const AvailabilityRulesResponse._();

  @jsonSerializable
  const factory AvailabilityRulesResponse({
    /// items
    @JsonKey(name: AvailabilityRulesResponse.itemsKey_)
    List<AvailabilityRuleView>? items,
  }) = _AvailabilityRulesResponse;

  factory AvailabilityRulesResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRulesResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
