// NicheBannerStyle
// {
//     "type": "string",
//     "enum": [
//         "image",
//         "text"
//     ],
//     "title": "NicheBannerStyle"
// }

library niche_banner_style;

import 'exports.dart';
part 'niche_banner_style.g.dart';

@JsonEnum(alwaysCreate: true)
enum NicheBannerStyle {
  @JsonValue("image")
  image,
  @JsonValue("text")
  text;

  factory NicheBannerStyle.fromJson(String json) =>
      NicheBannerStyle.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid NicheBannerStyle"),
      );

  String toJson() => _$NicheBannerStyleEnumMap[this]!;
}
