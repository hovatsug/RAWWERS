// MilestoneDifficulty
// {
//     "type": "string",
//     "enum": [
//         "standard",
//         "advanced",
//         "elite"
//     ],
//     "title": "MilestoneDifficulty"
// }

library milestone_difficulty;

import 'exports.dart';
part 'milestone_difficulty.g.dart';

@JsonEnum(alwaysCreate: true)
enum MilestoneDifficulty {
  @JsonValue("standard")
  standard,
  @JsonValue("advanced")
  advanced,
  @JsonValue("elite")
  elite;

  factory MilestoneDifficulty.fromJson(String json) =>
      MilestoneDifficulty.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MilestoneDifficulty"),
      );

  String toJson() => _$MilestoneDifficultyEnumMap[this]!;
}
