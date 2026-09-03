// PayoutRequestStatus
// {
//     "type": "string",
//     "enum": [
//         "requested",
//         "approved",
//         "rejected",
//         "processing",
//         "paid",
//         "failed",
//         "cancelled"
//     ],
//     "title": "PayoutRequestStatus"
// }

library payout_request_status;

import 'exports.dart';
part 'payout_request_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum PayoutRequestStatus {
  @JsonValue("requested")
  requested,
  @JsonValue("approved")
  approved,
  @JsonValue("rejected")
  rejected,
  @JsonValue("processing")
  processing,
  @JsonValue("paid")
  paid,
  @JsonValue("failed")
  failed,
  @JsonValue("cancelled")
  cancelled;

  factory PayoutRequestStatus.fromJson(String json) =>
      PayoutRequestStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid PayoutRequestStatus"),
      );

  String toJson() => _$PayoutRequestStatusEnumMap[this]!;
}
