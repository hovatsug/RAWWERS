// CallPurpose
// {
//     "type": "string",
//     "enum": [
//         "booking_confirmation",
//         "payment_nudge",
//         "request_nudge",
//         "reschedule"
//     ],
//     "title": "CallPurpose"
// }

library call_purpose;

import 'exports.dart';
part 'call_purpose.g.dart';

@JsonEnum(alwaysCreate: true)
enum CallPurpose {
  @JsonValue("booking_confirmation")
  bookingConfirmation,
  @JsonValue("payment_nudge")
  paymentNudge,
  @JsonValue("request_nudge")
  requestNudge,
  @JsonValue("reschedule")
  reschedule;

  factory CallPurpose.fromJson(String json) => CallPurpose.values.firstWhere(
    (e) => e.toJson() == json,
    orElse: () => throw ArgumentError("Invalid CallPurpose"),
  );

  String toJson() => _$CallPurposeEnumMap[this]!;
}
