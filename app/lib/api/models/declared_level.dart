// DeclaredLevel
// {
//     "type": "string",
//     "enum": [
//         "beginner",
//         "intermediate",
//         "advanced",
//         "expert"
//     ],
//     "title": "DeclaredLevel"
// }

library declared_level;

import 'exports.dart';
part 'declared_level.g.dart';

@JsonEnum(alwaysCreate: true)
enum DeclaredLevel {
  @JsonValue("beginner")
  beginner,
  @JsonValue("intermediate")
  intermediate,
  @JsonValue("advanced")
  advanced,
  @JsonValue("expert")
  expert;

  factory DeclaredLevel.fromJson(String json) =>
      DeclaredLevel.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid DeclaredLevel"),
      );

  String toJson() => _$DeclaredLevelEnumMap[this]!;
}
