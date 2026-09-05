// GearCategory
// {
//     "type": "string",
//     "enum": [
//         "camera_body",
//         "lens",
//         "lighting",
//         "audio",
//         "tripod",
//         "drone",
//         "accessory"
//     ],
//     "title": "GearCategory"
// }

library gear_category;

import 'exports.dart';
part 'gear_category.g.dart';

@JsonEnum(alwaysCreate: true)
enum GearCategory {
  @JsonValue("camera_body")
  cameraBody,
  @JsonValue("lens")
  lens,
  @JsonValue("lighting")
  lighting,
  @JsonValue("audio")
  audio,
  @JsonValue("tripod")
  tripod,
  @JsonValue("drone")
  drone,
  @JsonValue("accessory")
  accessory;

  factory GearCategory.fromJson(String json) => GearCategory.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid GearCategory"),
  );

  String toJson() => _$GearCategoryEnumMap[this]!;
}
