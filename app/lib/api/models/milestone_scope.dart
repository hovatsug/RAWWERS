// MilestoneScope
// {
//     "type": "string",
//     "enum": [
//         "global",
//         "niche"
//     ],
//     "title": "MilestoneScope"
// }

library milestone_scope;

import 'exports.dart';
part 'milestone_scope.g.dart';

@JsonEnum(alwaysCreate: true)
enum MilestoneScope {
  @JsonValue("global")
  global,
  @JsonValue("niche")
  niche;

  factory MilestoneScope.fromJson(String json) =>
      MilestoneScope.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MilestoneScope"),
      );

  String toJson() => _$MilestoneScopeEnumMap[this]!;
}
