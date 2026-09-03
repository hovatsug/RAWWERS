// ProofGalleryStatus
// {
//     "type": "string",
//     "enum": [
//         "draft",
//         "published",
//         "selection_submitted",
//         "delivered"
//     ],
//     "title": "ProofGalleryStatus"
// }

library proof_gallery_status;

import 'exports.dart';
part 'proof_gallery_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum ProofGalleryStatus {
  @JsonValue("draft")
  draft,
  @JsonValue("published")
  published,
  @JsonValue("selection_submitted")
  selectionSubmitted,
  @JsonValue("delivered")
  delivered;

  factory ProofGalleryStatus.fromJson(String json) =>
      ProofGalleryStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid ProofGalleryStatus"),
      );

  String toJson() => _$ProofGalleryStatusEnumMap[this]!;
}
