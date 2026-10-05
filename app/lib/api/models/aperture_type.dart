// ApertureType
// {
//     "type": "string",
//     "enum": [
//         "prime",
//         "fixed_zoom",
//         "variable_zoom"
//     ],
//     "title": "ApertureType",
//     "description": "Whether a lens holds its maximum aperture across its range."
// }

library aperture_type;

import 'exports.dart';
part 'aperture_type.g.dart';

@JsonEnum(alwaysCreate: true)
enum ApertureType {
  @JsonValue("prime")
  prime,
  @JsonValue("fixed_zoom")
  fixedZoom,
  @JsonValue("variable_zoom")
  variableZoom;

  factory ApertureType.fromJson(String json) => ApertureType.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid ApertureType"),
  );

  String toJson() => _$ApertureTypeEnumMap[this]!;
}
