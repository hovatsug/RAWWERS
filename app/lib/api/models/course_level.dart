// CourseLevel
// {
//     "type": "string",
//     "enum": [
//         "beginner",
//         "intermediate",
//         "advanced",
//         "master"
//     ],
//     "title": "CourseLevel"
// }

library course_level;

import 'exports.dart';
part 'course_level.g.dart';

@JsonEnum(alwaysCreate: true)
enum CourseLevel {
  @JsonValue("beginner")
  beginner,
  @JsonValue("intermediate")
  intermediate,
  @JsonValue("advanced")
  advanced,
  @JsonValue("master")
  master;

  factory CourseLevel.fromJson(String json) => CourseLevel.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid CourseLevel"),
  );

  String toJson() => _$CourseLevelEnumMap[this]!;
}
