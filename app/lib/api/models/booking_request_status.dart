// BookingRequestStatus
// {
//     "type": "string",
//     "enum": [
//         "pending",
//         "accepted",
//         "declined",
//         "expired",
//         "cancelled"
//     ],
//     "title": "BookingRequestStatus"
// }

library booking_request_status;

import 'exports.dart';
part 'booking_request_status.g.dart';

@JsonEnum(alwaysCreate: true)
enum BookingRequestStatus {
  @JsonValue("pending")
  pending,
  @JsonValue("accepted")
  accepted,
  @JsonValue("declined")
  declined,
  @JsonValue("expired")
  expired,
  @JsonValue("cancelled")
  cancelled;

  factory BookingRequestStatus.fromJson(String json) =>
      BookingRequestStatus.values.firstWhere(
        (e) => e.toJson() == json,
        orElse: () => throw ArgumentError("Invalid BookingRequestStatus"),
      );

  String toJson() => _$BookingRequestStatusEnumMap[this]!;
}
