/// AvailabilityRulesReplaceRequest
/// {
///     "properties": {
///         "rules": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/AvailabilityRuleItem"
///             },
///             "title": "Rules"
///         }
///     },
///     "type": "object",
///     "title": "AvailabilityRulesReplaceRequest"
/// }
library availability_rules_replace_request;

import 'exports.dart';
part 'availability_rules_replace_request.freezed.dart';
part 'availability_rules_replace_request.g.dart'; // AvailabilityRulesReplaceRequest

@freezed
abstract class AvailabilityRulesReplaceRequest
    with _$AvailabilityRulesReplaceRequest {
  const AvailabilityRulesReplaceRequest._();

  @jsonSerializable
  const factory AvailabilityRulesReplaceRequest({
    /// rules
    @JsonKey(name: AvailabilityRulesReplaceRequest.rulesKey_)
    List<AvailabilityRuleItem>? rules,
  }) = _AvailabilityRulesReplaceRequest;

  factory AvailabilityRulesReplaceRequest.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRulesReplaceRequestFromJson(json);

  static const String rulesKey_ = r'rules';
}
