// PaymentStatus
// {
//     "type": "string",
//     "enum": [
//         "pending",
//         "requires_action",
//         "succeeded",
//         "failed",
//         "cancelled",
//         "refunded",
//         "disputed"
//     ],
//     "title": "PaymentStatus"
// }

library payment_status;

import 'exports.dart';
part 'payment_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum PaymentStatus {
  @JsonValue("pending")
  pending,
  @JsonValue("requires_action")
  requiresAction,
  @JsonValue("succeeded")
  succeeded,
  @JsonValue("failed")
  failed,
  @JsonValue("cancelled")
  cancelled,
  @JsonValue("refunded")
  refunded,
  @JsonValue("disputed")
  disputed;

  factory PaymentStatus.fromJson(String json) =>
      PaymentStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid PaymentStatus"),
      );

  String toJson() => _$PaymentStatusEnumMap[this]!;
}
