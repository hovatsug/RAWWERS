/// ClientBookingRefund
/// {
///     "properties": {
///         "amount": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "reasons": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Reasons"
///         },
///         "at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "amount",
///         "currency",
///         "reasons",
///         "at"
///     ],
///     "title": "ClientBookingRefund",
///     "description": "A refund the client is getting because the price came down, with\nthe reasons in the words the admin-editable reason list gives them."
/// }
library client_booking_refund;

import 'exports.dart';
part 'client_booking_refund.freezed.dart';
part 'client_booking_refund.g.dart'; // ClientBookingRefund

@freezed
abstract class ClientBookingRefund with _$ClientBookingRefund {
  const ClientBookingRefund._();

  @jsonSerializable
  const factory ClientBookingRefund({
    /// amount
    @JsonKey(name: ClientBookingRefund.amountKey_) required String amount,

    /// currency
    @JsonKey(name: ClientBookingRefund.currencyKey_) required String currency,

    /// reasons
    @JsonKey(name: ClientBookingRefund.reasonsKey_)
    required List<String> reasons,

    /// at
    @JsonKey(name: ClientBookingRefund.atKey_) required DateTime at,
  }) = _ClientBookingRefund;

  factory ClientBookingRefund.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingRefundFromJson(json);

  static const String amountKey_ = r'amount';

  static const String currencyKey_ = r'currency';

  static const String reasonsKey_ = r'reasons';

  static const String atKey_ = r'at';
}
