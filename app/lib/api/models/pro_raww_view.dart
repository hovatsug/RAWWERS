/// ProRawwView
/// {
///     "properties": {
///         "shelf_open": {
///             "type": "boolean",
///             "title": "Shelf Open"
///         },
///         "spendable": {
///             "type": "integer",
///             "title": "Spendable"
///         },
///         "pending": {
///             "type": "integer",
///             "title": "Pending"
///         },
///         "raww_eur_value": {
///             "type": "string",
///             "title": "Raww Eur Value"
///         },
///         "pending_bookings": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/RawwPendingBooking"
///             },
///             "title": "Pending Bookings"
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
///         "expiry_warning": {
///             "type": "boolean",
///             "title": "Expiry Warning"
///         },
///         "inactivity_months": {
///             "type": "integer",
///             "title": "Inactivity Months"
///         }
///     },
///     "type": "object",
///     "required": [
///         "shelf_open",
///         "spendable",
///         "pending",
///         "raww_eur_value",
///         "pending_bookings",
///         "expiry_warning",
///         "inactivity_months"
///     ],
///     "title": "ProRawwView"
/// }
library pro_raww_view;

import 'exports.dart';
part 'pro_raww_view.freezed.dart';
part 'pro_raww_view.g.dart'; // ProRawwView

@freezed
abstract class ProRawwView with _$ProRawwView {
  const ProRawwView._();

  @jsonSerializable
  const factory ProRawwView({
    /// shelfOpen
    @JsonKey(name: ProRawwView.shelfOpenKey_) required bool shelfOpen,

    /// spendable
    @JsonKey(name: ProRawwView.spendableKey_) required int spendable,

    /// pending
    @JsonKey(name: ProRawwView.pendingKey_) required int pending,

    /// rawwEurValue
    @JsonKey(name: ProRawwView.rawwEurValueKey_) required String rawwEurValue,

    /// pendingBookings
    @JsonKey(name: ProRawwView.pendingBookingsKey_)
    required List<RawwPendingBooking> pendingBookings,

    /// expiresAt
    @JsonKey(name: ProRawwView.expiresAtKey_) DateTime? expiresAt,

    /// expiryWarning
    @JsonKey(name: ProRawwView.expiryWarningKey_) required bool expiryWarning,

    /// inactivityMonths
    @JsonKey(name: ProRawwView.inactivityMonthsKey_)
    required int inactivityMonths,
  }) = _ProRawwView;

  factory ProRawwView.fromJson(Map<String, dynamic> json) =>
      _$ProRawwViewFromJson(json);

  static const String shelfOpenKey_ = r'shelf_open';

  static const String spendableKey_ = r'spendable';

  static const String pendingKey_ = r'pending';

  static const String rawwEurValueKey_ = r'raww_eur_value';

  static const String pendingBookingsKey_ = r'pending_bookings';

  static const String expiresAtKey_ = r'expires_at';

  static const String expiryWarningKey_ = r'expiry_warning';

  static const String inactivityMonthsKey_ = r'inactivity_months';
}
