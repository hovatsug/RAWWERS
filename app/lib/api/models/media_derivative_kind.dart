// MediaDerivativeKind
// {
//     "type": "string",
//     "enum": [
//         "preview_watermarked",
//         "web_res",
//         "full_res",
//         "thumbnail"
//     ],
//     "title": "MediaDerivativeKind"
// }

library media_derivative_kind;

import 'exports.dart';
part 'media_derivative_kind.g.dart';

@JsonEnum(alwaysCreate: true)
enum MediaDerivativeKind {
  @JsonValue("preview_watermarked")
  previewWatermarked,
  @JsonValue("web_res")
  webRes,
  @JsonValue("full_res")
  fullRes,
  @JsonValue("thumbnail")
  thumbnail;

  factory MediaDerivativeKind.fromJson(String json) =>
      MediaDerivativeKind.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MediaDerivativeKind"),
      );

  String toJson() => _$MediaDerivativeKindEnumMap[this]!;
}
