/// RawwPendingBooking
/// {
///     "properties": {
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "amount": {
///             "type": "integer",
///             "title": "Amount"
///         },
///         "held": {
///             "type": "boolean",
///             "title": "Held"
///         },
///         "expected_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Expected At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig_id",
///         "amount",
///         "held"
///     ],
///     "title": "RawwPendingBooking"
/// }
library raww_pending_booking;

import 'exports.dart';
part 'raww_pending_booking.freezed.dart';
part 'raww_pending_booking.g.dart'; // RawwPendingBooking

@freezed
abstract class RawwPendingBooking with _$RawwPendingBooking {
  const RawwPendingBooking._();

  @jsonSerializable
  const factory RawwPendingBooking({
    /// gigId
    @JsonKey(name: RawwPendingBooking.gigIdKey_) required String gigId,

    /// amount
    @JsonKey(name: RawwPendingBooking.amountKey_) required int amount,

    /// held
    @JsonKey(name: RawwPendingBooking.heldKey_) required bool held,

    /// expectedAt
    @JsonKey(name: RawwPendingBooking.expectedAtKey_) DateTime? expectedAt,
  }) = _RawwPendingBooking;

  factory RawwPendingBooking.fromJson(Map<String, dynamic> json) =>
      _$RawwPendingBookingFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String amountKey_ = r'amount';

  static const String heldKey_ = r'held';

  static const String expectedAtKey_ = r'expected_at';
}
