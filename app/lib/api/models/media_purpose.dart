// MediaPurpose
// {
//     "type": "string",
//     "enum": [
//         "portfolio_reel",
//         "video_review",
//         "proof",
//         "final_delivery",
//         "gear_evidence",
//         "niche_banner",
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
  @JsonValue("gear_evidence")
  gearEvidence,
  @JsonValue("niche_banner")
  nicheBanner,
  @JsonValue("other")
  other;

  factory MediaPurpose.fromJson(String json) => MediaPurpose.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid MediaPurpose"),
  );

  String toJson() => _$MediaPurposeEnumMap[this]!;
}
