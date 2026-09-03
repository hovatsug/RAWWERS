// CallSessionStatus
// {
//     "type": "string",
//     "enum": [
//         "queued",
//         "dialing",
//         "in_progress",
//         "completed",
//         "failed",
//         "cancelled"
//     ],
//     "title": "CallSessionStatus"
// }

library call_session_status;

import 'exports.dart';
part 'call_session_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum CallSessionStatus {
  @JsonValue("queued")
  queued,
  @JsonValue("dialing")
  dialing,
  @JsonValue("in_progress")
  inProgress,
  @JsonValue("completed")
  completed,
  @JsonValue("failed")
  failed,
  @JsonValue("cancelled")
  cancelled;

  factory CallSessionStatus.fromJson(String json) =>
      CallSessionStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid CallSessionStatus"),
      );

  String toJson() => _$CallSessionStatusEnumMap[this]!;
}
