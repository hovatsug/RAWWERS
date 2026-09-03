// ReviewStatus
// {
//     "type": "string",
//     "enum": [
//         "published",
//         "hidden",
//         "removed"
//     ],
//     "title": "ReviewStatus"
// }

library review_status;

import 'exports.dart';
part 'review_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum ReviewStatus {
  @JsonValue("published")
  published,
  @JsonValue("hidden")
  hidden,
  @JsonValue("removed")
  removed;

  factory ReviewStatus.fromJson(String json) => ReviewStatus.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid ReviewStatus"),
  );

  String toJson() => _$ReviewStatusEnumMap[this]!;
}
