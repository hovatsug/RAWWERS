// CallOutcome
// {
//     "type": "string",
//     "enum": [
//         "connected",
//         "no_answer",
//         "busy",
//         "failed",
//         "voicemail",
//         "cancelled",
//         "unknown"
//     ],
//     "title": "CallOutcome"
// }

library call_outcome;

import 'exports.dart';
part 'call_outcome.g.dart';

@JsonEnum(alwaysCreate: true)
enum CallOutcome {
  @JsonValue("connected")
  connected,
  @JsonValue("no_answer")
  noAnswer,
  @JsonValue("busy")
  busy,
  @JsonValue("failed")
  failed,
  @JsonValue("voicemail")
  voicemail,
  @JsonValue("cancelled")
  cancelled,
  @JsonValue("unknown")
  unknown;

  factory CallOutcome.fromJson(String json) => CallOutcome.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid CallOutcome"),
  );

  String toJson() => _$CallOutcomeEnumMap[this]!;
}
