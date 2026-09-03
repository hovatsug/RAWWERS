/// ClientBookingStatusResponse
/// {
///     "properties": {
///         "booking_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Booking Id"
///         },
///         "booking_status": {
///             "type": "string",
///             "title": "Booking Status"
///         },
///         "gig_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gig Id"
///         },
///         "gig_status": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gig Status"
///         },
///         "payment_status": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Payment Status"
///         },
///         "timeline": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Timeline"
///         },
///         "next_actions": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Next Actions"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_id",
///         "booking_status"
///     ],
///     "title": "ClientBookingStatusResponse"
/// }
library client_booking_status_response;

import 'exports.dart';
part 'client_booking_status_response.freezed.dart';
part 'client_booking_status_response.g.dart'; // ClientBookingStatusResponse

@freezed
abstract class ClientBookingStatusResponse with _$ClientBookingStatusResponse {
  const ClientBookingStatusResponse._();

  @jsonSerializable
  const factory ClientBookingStatusResponse({
    /// bookingId
    @JsonKey(name: ClientBookingStatusResponse.bookingIdKey_)
    required String bookingId,

    /// bookingStatus
    @JsonKey(name: ClientBookingStatusResponse.bookingStatusKey_)
    required String bookingStatus,

    /// gigId
    @JsonKey(name: ClientBookingStatusResponse.gigIdKey_) String? gigId,

    /// gigStatus
    @JsonKey(name: ClientBookingStatusResponse.gigStatusKey_) String? gigStatus,

    /// paymentStatus
    @JsonKey(name: ClientBookingStatusResponse.paymentStatusKey_)
    String? paymentStatus,

    /// timeline
    @JsonKey(name: ClientBookingStatusResponse.timelineKey_)
    List<Map<String, dynamic>>? timeline,

    /// nextActions
    @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_)
    List<String>? nextActions,
  }) = _ClientBookingStatusResponse;

  factory ClientBookingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingStatusResponseFromJson(json);

  static const String bookingIdKey_ = r'booking_id';

  static const String bookingStatusKey_ = r'booking_status';

  static const String gigIdKey_ = r'gig_id';

  static const String gigStatusKey_ = r'gig_status';

  static const String paymentStatusKey_ = r'payment_status';

  static const String timelineKey_ = r'timeline';

  static const String nextActionsKey_ = r'next_actions';
}
