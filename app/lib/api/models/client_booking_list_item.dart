/// ClientBookingListItem
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
///         "requested_start": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Requested Start"
///         },
///         "requested_end": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Requested End"
///         },
///         "location_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Location Text"
///         },
///         "expires_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Expires At"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "booking_id",
///         "booking_status",
///         "requested_start",
///         "requested_end",
///         "expires_at",
///         "created_at"
///     ],
///     "title": "ClientBookingListItem",
///     "description": "Summary row for the client's bookings list.\n\nCarries the same booking/gig/payment status triple the detail route\nleads with, so a list row and a detail header agree, but omits\n`timeline` and `next_actions`: both are computed per booking (the\ntimeline is a second query for transitions) and neither is rendered in\na list. The detail route remains the way to get them."
/// }
library client_booking_list_item;

import 'exports.dart';
part 'client_booking_list_item.freezed.dart';
part 'client_booking_list_item.g.dart'; // ClientBookingListItem

@freezed
abstract class ClientBookingListItem with _$ClientBookingListItem {
  const ClientBookingListItem._();

  @jsonSerializable
  const factory ClientBookingListItem({
    /// bookingId
    @JsonKey(name: ClientBookingListItem.bookingIdKey_)
    required String bookingId,

    /// bookingStatus
    @JsonKey(name: ClientBookingListItem.bookingStatusKey_)
    required String bookingStatus,

    /// gigId
    @JsonKey(name: ClientBookingListItem.gigIdKey_) String? gigId,

    /// gigStatus
    @JsonKey(name: ClientBookingListItem.gigStatusKey_) String? gigStatus,

    /// paymentStatus
    @JsonKey(name: ClientBookingListItem.paymentStatusKey_)
    String? paymentStatus,

    /// requestedStart
    @JsonKey(name: ClientBookingListItem.requestedStartKey_)
    required DateTime requestedStart,

    /// requestedEnd
    @JsonKey(name: ClientBookingListItem.requestedEndKey_)
    required DateTime requestedEnd,

    /// locationText
    @JsonKey(name: ClientBookingListItem.locationTextKey_) String? locationText,

    /// expiresAt
    @JsonKey(name: ClientBookingListItem.expiresAtKey_)
    required DateTime expiresAt,

    /// createdAt
    @JsonKey(name: ClientBookingListItem.createdAtKey_)
    required DateTime createdAt,
  }) = _ClientBookingListItem;

  factory ClientBookingListItem.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingListItemFromJson(json);

  static const String bookingIdKey_ = r'booking_id';

  static const String bookingStatusKey_ = r'booking_status';

  static const String gigIdKey_ = r'gig_id';

  static const String gigStatusKey_ = r'gig_status';

  static const String paymentStatusKey_ = r'payment_status';

  static const String requestedStartKey_ = r'requested_start';

  static const String requestedEndKey_ = r'requested_end';

  static const String locationTextKey_ = r'location_text';

  static const String expiresAtKey_ = r'expires_at';

  static const String createdAtKey_ = r'created_at';
}
