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
///         "proof_gallery_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Proof Gallery Id"
///         },
///         "proof_gallery_status": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Proof Gallery Status"
///         },
///         "expires_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Expires At"
///         },
///         "short_notice": {
///             "type": "boolean",
///             "default": false,
///             "title": "Short Notice"
///         },
///         "refunds": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientBookingRefund"
///             },
///             "default": [],
///             "title": "Refunds"
///         },
///         "pay_by": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Pay By"
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
///         },
///         "review": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/ReviewView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
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

    /// proofGalleryId
    @JsonKey(name: ClientBookingStatusResponse.proofGalleryIdKey_)
    String? proofGalleryId,

    /// proofGalleryStatus
    @JsonKey(name: ClientBookingStatusResponse.proofGalleryStatusKey_)
    String? proofGalleryStatus,

    /// expiresAt
    @JsonKey(name: ClientBookingStatusResponse.expiresAtKey_)
    DateTime? expiresAt,

    /// shortNotice
    @Default(false)
    @JsonKey(name: ClientBookingStatusResponse.shortNoticeKey_)
    bool shortNotice,

    /// refunds
    @Default(const [])
    @JsonKey(name: ClientBookingStatusResponse.refundsKey_)
    List<ClientBookingRefund> refunds,

    /// payBy
    @JsonKey(name: ClientBookingStatusResponse.payByKey_) DateTime? payBy,

    /// timeline
    @JsonKey(name: ClientBookingStatusResponse.timelineKey_)
    List<Map<String, dynamic>>? timeline,

    /// nextActions
    @JsonKey(name: ClientBookingStatusResponse.nextActionsKey_)
    List<String>? nextActions,

    /// review
    @JsonKey(name: ClientBookingStatusResponse.reviewKey_) ReviewView? review,
  }) = _ClientBookingStatusResponse;

  factory ClientBookingStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingStatusResponseFromJson(json);

  static const String bookingIdKey_ = r'booking_id';

  static const String bookingStatusKey_ = r'booking_status';

  static const String gigIdKey_ = r'gig_id';

  static const String gigStatusKey_ = r'gig_status';

  static const String paymentStatusKey_ = r'payment_status';

  static const String proofGalleryIdKey_ = r'proof_gallery_id';

  static const String proofGalleryStatusKey_ = r'proof_gallery_status';

  static const String expiresAtKey_ = r'expires_at';

  static const String shortNoticeKey_ = r'short_notice';

  static const String refundsKey_ = r'refunds';

  static const String payByKey_ = r'pay_by';

  static const String timelineKey_ = r'timeline';

  static const String nextActionsKey_ = r'next_actions';

  static const String reviewKey_ = r'review';
}
