// SkillTier
// {
//     "type": "string",
//     "enum": [
//         "rookie",
//         "skilled",
//         "pro",
//         "elite",
//         "master"
//     ],
//     "title": "SkillTier"
// }

library skill_tier;

import 'exports.dart';
part 'skill_tier.g.dart';

@JsonEnum(alwaysCreate: true)
enum SkillTier {
  @JsonValue("rookie")
  rookie,
  @JsonValue("skilled")
  skilled,
  @JsonValue("pro")
  pro,
  @JsonValue("elite")
  elite,
  @JsonValue("master")
  master;

  factory SkillTier.fromJson(String json) => SkillTier.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid SkillTier"),
  );

  String toJson() => _$SkillTierEnumMap[this]!;
}
