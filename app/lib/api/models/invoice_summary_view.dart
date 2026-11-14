/// InvoiceSummaryView
/// {
///     "properties": {
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "bookings": {
///             "type": "integer",
///             "title": "Bookings"
///         },
///         "gross": {
///             "type": "string",
///             "title": "Gross"
///         },
///         "platform_fees": {
///             "type": "string",
///             "title": "Platform Fees"
///         },
///         "pro_raww": {
///             "type": "string",
///             "title": "Pro Raww"
///         },
///         "extras_pro_raww": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Extras Pro Raww"
///         },
///         "pro_raww_rawws": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Pro Raww Rawws"
///         },
///         "client_raww": {
///             "type": "string",
///             "title": "Client Raww"
///         },
///         "pro_cash": {
///             "type": "string",
///             "title": "Pro Cash"
///         },
///         "average_gross": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Average Gross"
///         },
///         "reconstructed": {
///             "type": "integer",
///             "default": 0,
///             "title": "Reconstructed"
///         }
///     },
///     "type": "object",
///     "required": [
///         "currency",
///         "bookings",
///         "gross",
///         "platform_fees",
///         "pro_raww",
///         "client_raww",
///         "pro_cash"
///     ],
///     "title": "InvoiceSummaryView",
///     "description": "Totals across every completed, invoiced gig, in the photographer's\none currency."
/// }
library invoice_summary_view;

import 'exports.dart';
part 'invoice_summary_view.freezed.dart';
part 'invoice_summary_view.g.dart'; // InvoiceSummaryView

@freezed
abstract class InvoiceSummaryView with _$InvoiceSummaryView {
  const InvoiceSummaryView._();

  @jsonSerializable
  const factory InvoiceSummaryView({
    /// currency
    @JsonKey(name: InvoiceSummaryView.currencyKey_) required String currency,

    /// bookings
    @JsonKey(name: InvoiceSummaryView.bookingsKey_) required int bookings,

    /// gross
    @JsonKey(name: InvoiceSummaryView.grossKey_) required String gross,

    /// platformFees
    @JsonKey(name: InvoiceSummaryView.platformFeesKey_)
    required String platformFees,

    /// proRaww
    @JsonKey(name: InvoiceSummaryView.proRawwKey_) required String proRaww,

    /// extrasProRaww
    @Default('0.00')
    @JsonKey(name: InvoiceSummaryView.extrasProRawwKey_)
    String extrasProRaww,

    /// proRawwRawws
    @JsonKey(name: InvoiceSummaryView.proRawwRawwsKey_) int? proRawwRawws,

    /// clientRaww
    @JsonKey(name: InvoiceSummaryView.clientRawwKey_)
    required String clientRaww,

    /// proCash
    @JsonKey(name: InvoiceSummaryView.proCashKey_) required String proCash,

    /// averageGross
    @JsonKey(name: InvoiceSummaryView.averageGrossKey_) String? averageGross,

    /// reconstructed
    @Default(0)
    @JsonKey(name: InvoiceSummaryView.reconstructedKey_)
    int reconstructed,
  }) = _InvoiceSummaryView;

  factory InvoiceSummaryView.fromJson(Map<String, dynamic> json) =>
      _$InvoiceSummaryViewFromJson(json);

  static const String currencyKey_ = r'currency';

  static const String bookingsKey_ = r'bookings';

  static const String grossKey_ = r'gross';

  static const String platformFeesKey_ = r'platform_fees';

  static const String proRawwKey_ = r'pro_raww';

  static const String extrasProRawwKey_ = r'extras_pro_raww';

  static const String proRawwRawwsKey_ = r'pro_raww_rawws';

  static const String clientRawwKey_ = r'client_raww';

  static const String proCashKey_ = r'pro_cash';

  static const String averageGrossKey_ = r'average_gross';

  static const String reconstructedKey_ = r'reconstructed';
}
