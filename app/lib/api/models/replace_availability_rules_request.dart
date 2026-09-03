/// ReplaceAvailabilityRulesRequest
/// {
///     "properties": {
///         "rules": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/AvailabilityRuleInput"
///             },
///             "title": "Rules"
///         }
///     },
///     "type": "object",
///     "required": [
///         "rules"
///     ],
///     "title": "ReplaceAvailabilityRulesRequest"
/// }
library replace_availability_rules_request;

import 'exports.dart';
part 'replace_availability_rules_request.freezed.dart';
part 'replace_availability_rules_request.g.dart'; // ReplaceAvailabilityRulesRequest

@freezed
abstract class ReplaceAvailabilityRulesRequest
    with _$ReplaceAvailabilityRulesRequest {
  const ReplaceAvailabilityRulesRequest._();

  @jsonSerializable
  const factory ReplaceAvailabilityRulesRequest({
    /// rules
    @JsonKey(name: ReplaceAvailabilityRulesRequest.rulesKey_)
    required List<AvailabilityRuleInput> rules,
  }) = _ReplaceAvailabilityRulesRequest;

  factory ReplaceAvailabilityRulesRequest.fromJson(Map<String, dynamic> json) =>
      _$ReplaceAvailabilityRulesRequestFromJson(json);

  static const String rulesKey_ = r'rules';
}
