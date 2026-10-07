// SchedulingPreset
// {
//     "type": "string",
//     "enum": [
//         "interval",
//         "blocks",
//         "full_day"
//     ],
//     "title": "SchedulingPreset",
//     "description": "How a package's bookable times are laid out - see bookable_time."
// }

library scheduling_preset;

import 'exports.dart';
part 'scheduling_preset.g.dart';

@JsonEnum(alwaysCreate: true)
enum SchedulingPreset {
  @JsonValue("interval")
  interval,
  @JsonValue("blocks")
  blocks,
  @JsonValue("full_day")
  fullDay;

  factory SchedulingPreset.fromJson(String json) =>
      SchedulingPreset.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid SchedulingPreset"),
      );

  String toJson() => _$SchedulingPresetEnumMap[this]!;
}
