// MilestoneAudience
// {
//     "type": "string",
//     "enum": [
//         "pro",
//         "client",
//         "both"
//     ],
//     "title": "MilestoneAudience"
// }

library milestone_audience;

import 'exports.dart';
part 'milestone_audience.g.dart';

@JsonEnum(alwaysCreate: true)
enum MilestoneAudience {
  @JsonValue("pro")
  pro,
  @JsonValue("client")
  client,
  @JsonValue("both")
  both;

  factory MilestoneAudience.fromJson(String json) =>
      MilestoneAudience.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MilestoneAudience"),
      );

  String toJson() => _$MilestoneAudienceEnumMap[this]!;
}
