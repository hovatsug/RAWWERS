// AvailabilityLocationMode
// {
//     "type": "string",
//     "enum": [
//         "on_site",
//         "studio",
//         "both"
//     ],
//     "title": "AvailabilityLocationMode"
// }

library availability_location_mode;

import 'exports.dart';
part 'availability_location_mode.g.dart';

@JsonEnum(alwaysCreate: true)
enum AvailabilityLocationMode {
  @JsonValue("on_site")
  onSite,
  @JsonValue("studio")
  studio,
  @JsonValue("both")
  both;

  factory AvailabilityLocationMode.fromJson(String json) =>
      AvailabilityLocationMode.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid AvailabilityLocationMode"),
      );

  String toJson() => _$AvailabilityLocationModeEnumMap[this]!;
}
