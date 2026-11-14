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
//         "banner_placeholder",
//         "shelf_400",
//         "shelf_800",
//         "shelf_1600"
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
  bannerPlaceholder,
  @JsonValue("shelf_400")
  shelf400,
  @JsonValue("shelf_800")
  shelf800,
  @JsonValue("shelf_1600")
  shelf1600;

  factory MediaDerivativeKind.fromJson(String json) =>
      MediaDerivativeKind.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid MediaDerivativeKind"),
      );

  String toJson() => _$MediaDerivativeKindEnumMap[this]!;
}
