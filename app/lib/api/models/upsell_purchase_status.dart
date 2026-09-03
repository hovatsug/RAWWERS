// UpsellPurchaseStatus
// {
//     "type": "string",
//     "enum": [
//         "pending",
//         "succeeded",
//         "failed",
//         "refunded"
//     ],
//     "title": "UpsellPurchaseStatus"
// }

library upsell_purchase_status;

import 'exports.dart';
part 'upsell_purchase_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum UpsellPurchaseStatus {
  @JsonValue("pending")
  pending,
  @JsonValue("succeeded")
  succeeded,
  @JsonValue("failed")
  failed,
  @JsonValue("refunded")
  refunded;

  factory UpsellPurchaseStatus.fromJson(String json) =>
      UpsellPurchaseStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid UpsellPurchaseStatus"),
      );

  String toJson() => _$UpsellPurchaseStatusEnumMap[this]!;
}
