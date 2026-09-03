// MediaPurpose
// {
//     "type": "string",
//     "enum": [
//         "portfolio_reel",
//         "video_review",
//         "proof",
//         "final_delivery",
//         "other"
//     ],
//     "title": "MediaPurpose"
// }

library media_purpose;

import 'exports.dart';
part 'media_purpose.g.dart';

@JsonEnum(alwaysCreate: true)
enum MediaPurpose {
  @JsonValue("portfolio_reel")
  portfolioReel,
  @JsonValue("video_review")
  videoReview,
  @JsonValue("proof")
  proof,
  @JsonValue("final_delivery")
  finalDelivery,
  @JsonValue("other")
  other;

  factory MediaPurpose.fromJson(String json) => MediaPurpose.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid MediaPurpose"),
  );

  String toJson() => _$MediaPurposeEnumMap[this]!;
}
