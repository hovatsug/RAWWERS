// MediaDerivativeKind
// {
//     "type": "string",
//     "enum": [
//         "preview_watermarked",
//         "web_res",
//         "full_res",
//         "thumbnail",
//         "banner_tile",
//         "banner_hero",
//         "banner_placeholder"
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
  thumbnail,
  @JsonValue("banner_tile")
  bannerTile,
  @JsonValue("banner_hero")
  bannerHero,
  @JsonValue("banner_placeholder")
  bannerPlaceholder;

  factory MediaDerivativeKind.fromJson(String json) =>
      MediaDerivativeKind.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MediaDerivativeKind"),
      );

  String toJson() => _$MediaDerivativeKindEnumMap[this]!;
}
