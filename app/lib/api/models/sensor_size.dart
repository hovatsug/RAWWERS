// SensorSize
// {
//     "type": "string",
//     "enum": [
//         "full_frame",
//         "crop",
//         "medium_format"
//     ],
//     "title": "SensorSize"
// }

library sensor_size;

import 'exports.dart';
part 'sensor_size.g.dart';

@JsonEnum(alwaysCreate: true)
enum SensorSize {
  @JsonValue("full_frame")
  fullFrame,
  @JsonValue("crop")
  crop,
  @JsonValue("medium_format")
  mediumFormat;

  factory SensorSize.fromJson(String json) => SensorSize.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid SensorSize"),
  );

  String toJson() => _$SensorSizeEnumMap[this]!;
}
