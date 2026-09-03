// ShareLinkScope
// {
//     "type": "string",
//     "enum": [
//         "proofs",
//         "finals",
//         "selected_only"
//     ],
//     "title": "ShareLinkScope"
// }

library share_link_scope;

import 'exports.dart';
part 'share_link_scope.g.dart';

@JsonEnum(alwaysCreate: true)
enum ShareLinkScope {
  @JsonValue("proofs")
  proofs,
  @JsonValue("finals")
  finals,
  @JsonValue("selected_only")
  selectedOnly;

  factory ShareLinkScope.fromJson(String json) =>
      ShareLinkScope.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ShareLinkScope"),
      );

  String toJson() => _$ShareLinkScopeEnumMap[this]!;
}
