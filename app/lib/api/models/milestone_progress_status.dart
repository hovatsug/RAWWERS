// MilestoneProgressStatus
// {
//     "type": "string",
//     "enum": [
//         "active",
//         "completed",
//         "expired"
//     ],
//     "title": "MilestoneProgressStatus"
// }

library milestone_progress_status;

import 'exports.dart';
part 'milestone_progress_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum MilestoneProgressStatus {
  @JsonValue("active")
  active,
  @JsonValue("completed")
  completed,
  @JsonValue("expired")
  expired;

  factory MilestoneProgressStatus.fromJson(String json) =>
      MilestoneProgressStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MilestoneProgressStatus"),
      );

  String toJson() => _$MilestoneProgressStatusEnumMap[this]!;
}
