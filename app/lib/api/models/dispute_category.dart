// DisputeCategory
// {
//     "type": "string",
//     "enum": [
//         "no_show",
//         "late_cancellation",
//         "late_delivery",
//         "deliverable_quality",
//         "billing",
//         "fraud",
//         "quality",
//         "harassment",
//         "payment",
//         "other"
//     ],
//     "title": "DisputeCategory"
// }

library dispute_category;

import 'exports.dart';
part 'dispute_category.g.dart';

@JsonEnum(alwaysCreate: true)
enum DisputeCategory {
  @JsonValue("no_show")
  noShow,
  @JsonValue("late_cancellation")
  lateCancellation,
  @JsonValue("late_delivery")
  lateDelivery,
  @JsonValue("deliverable_quality")
  deliverableQuality,
  @JsonValue("billing")
  billing,
  @JsonValue("fraud")
  fraud,
  @JsonValue("quality")
  quality,
  @JsonValue("harassment")
  harassment,
  @JsonValue("payment")
  payment,
  @JsonValue("other")
  other;

  factory DisputeCategory.fromJson(String json) =>
      DisputeCategory.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid DisputeCategory"),
      );

  String toJson() => _$DisputeCategoryEnumMap[this]!;
}
