// TeaserKind
// {
//     "type": "string",
//     "enum": [
//         "video",
//         "interview"
//     ],
//     "title": "TeaserKind"
// }

library teaser_kind;

import 'exports.dart';
part 'teaser_kind.g.dart';

@JsonEnum(alwaysCreate: true)
enum TeaserKind {
  @JsonValue("video")
  video,
  @JsonValue("interview")
  interview;

  factory TeaserKind.fromJson(String json) => TeaserKind.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid TeaserKind"),
  );

  String toJson() => _$TeaserKindEnumMap[this]!;
}
