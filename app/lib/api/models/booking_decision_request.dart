/// BookingDecisionRequest
/// {
///     "properties": {
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         }
///     },
///     "type": "object",
///     "title": "BookingDecisionRequest"
/// }
library booking_decision_request;

import 'exports.dart';
part 'booking_decision_request.freezed.dart';
part 'booking_decision_request.g.dart'; // BookingDecisionRequest

@freezed
abstract class BookingDecisionRequest with _$BookingDecisionRequest {
  const BookingDecisionRequest._();

  @jsonSerializable
  const factory BookingDecisionRequest({
    /// reason
    @JsonKey(name: BookingDecisionRequest.reasonKey_) String? reason,
  }) = _BookingDecisionRequest;

  factory BookingDecisionRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingDecisionRequestFromJson(json);

  static const String reasonKey_ = r'reason';
}
