// DisputeStatus
// {
//     "type": "string",
//     "enum": [
//         "open",
//         "awaiting_response",
//         "in_review",
//         "awaiting_admin",
//         "under_review",
//         "resolved_refund",
//         "resolved_no_refund",
//         "resolved_partial_refund",
//         "cancelled",
//         "closed"
//     ],
//     "title": "DisputeStatus"
// }

library dispute_status;

import 'exports.dart';
part 'dispute_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum DisputeStatus {
  @JsonValue("open")
  open,
  @JsonValue("awaiting_response")
  awaitingResponse,
  @JsonValue("in_review")
  inReview,
  @JsonValue("awaiting_admin")
  awaitingAdmin,
  @JsonValue("under_review")
  underReview,
  @JsonValue("resolved_refund")
  resolvedRefund,
  @JsonValue("resolved_no_refund")
  resolvedNoRefund,
  @JsonValue("resolved_partial_refund")
  resolvedPartialRefund,
  @JsonValue("cancelled")
  cancelled,
  @JsonValue("closed")
  closed;

  factory DisputeStatus.fromJson(String json) =>
      DisputeStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid DisputeStatus"),
      );

  String toJson() => _$DisputeStatusEnumMap[this]!;
}
