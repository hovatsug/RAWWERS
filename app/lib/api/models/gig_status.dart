// GigStatus
// {
//     "type": "string",
//     "enum": [
//         "draft",
//         "requested",
//         "accepted",
//         "payment_pending",
//         "paid",
//         "scheduled",
//         "shoot_done",
//         "proofs_delivered",
//         "selection_pending",
//         "final_delivered",
//         "completed",
//         "cancelled_by_client",
//         "cancelled_by_pro",
//         "refunded",
//         "disputed"
//     ],
//     "title": "GigStatus"
// }

library gig_status;

import 'exports.dart';
part 'gig_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum GigStatus {
  @JsonValue("draft")
  draft,
  @JsonValue("requested")
  requested,
  @JsonValue("accepted")
  accepted,
  @JsonValue("payment_pending")
  paymentPending,
  @JsonValue("paid")
  paid,
  @JsonValue("scheduled")
  scheduled,
  @JsonValue("shoot_done")
  shootDone,
  @JsonValue("proofs_delivered")
  proofsDelivered,
  @JsonValue("selection_pending")
  selectionPending,
  @JsonValue("final_delivered")
  finalDelivered,
  @JsonValue("completed")
  completed,
  @JsonValue("cancelled_by_client")
  cancelledByClient,
  @JsonValue("cancelled_by_pro")
  cancelledByPro,
  @JsonValue("refunded")
  refunded,
  @JsonValue("disputed")
  disputed;

  factory GigStatus.fromJson(String json) => GigStatus.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid GigStatus"),
  );

  String toJson() => _$GigStatusEnumMap[this]!;
}
