// ProblemReportReason
// {
//     "type": "string",
//     "enum": [
//         "photos_missing",
//         "wrong_photos",
//         "quality",
//         "not_as_agreed",
//         "other"
//     ],
//     "title": "ProblemReportReason",
//     "description": "What \"Report a problem\" offers, in the app's order."
// }

library problem_report_reason;

import 'exports.dart';
part 'problem_report_reason.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProblemReportReason {
  @JsonValue("photos_missing")
  photosMissing,
  @JsonValue("wrong_photos")
  wrongPhotos,
  @JsonValue("quality")
  quality,
  @JsonValue("not_as_agreed")
  notAsAgreed,
  @JsonValue("other")
  other;

  factory ProblemReportReason.fromJson(String json) =>
      ProblemReportReason.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ProblemReportReason"),
      );

  String toJson() => _$ProblemReportReasonEnumMap[this]!;
}
