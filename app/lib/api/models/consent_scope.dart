// ConsentScope
// {
//     "type": "string",
//     "enum": [
//         "transactional",
//         "marketing"
//     ],
//     "title": "ConsentScope"
// }

library consent_scope;

import 'exports.dart';
part 'consent_scope.g.dart';

@JsonEnum(alwaysCreate: true)
enum ConsentScope {
  @JsonValue("transactional")
  transactional,
  @JsonValue("marketing")
  marketing;

  factory ConsentScope.fromJson(String json) => ConsentScope.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid ConsentScope"),
  );

  String toJson() => _$ConsentScopeEnumMap[this]!;
}
