/// InvoiceSummaryView
/// {
///     "properties": {
///         "bookings": {
///             "type": "integer",
///             "title": "Bookings"
///         },
///         "gross": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Gross"
///         },
///         "platform_fees": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Platform Fees"
///         },
///         "pro_raww": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Pro Raww"
///         },
///         "client_raww": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Client Raww"
///         },
///         "pro_cash": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Pro Cash"
///         },
///         "average_gross": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
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
///         "bookings",
///         "gross",
///         "platform_fees",
///         "pro_raww",
///         "client_raww",
///         "pro_cash"
///     ],
///     "title": "InvoiceSummaryView",
///     "description": "Totals across every completed, invoiced gig."
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
    /// bookings
    @JsonKey(name: InvoiceSummaryView.bookingsKey_) required int bookings,

    /// gross
    @JsonKey(name: InvoiceSummaryView.grossKey_) required String gross,

    /// platformFees
    @JsonKey(name: InvoiceSummaryView.platformFeesKey_)
    required String platformFees,

    /// proRaww
    @JsonKey(name: InvoiceSummaryView.proRawwKey_) required String proRaww,

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

  static const String bookingsKey_ = r'bookings';

  static const String grossKey_ = r'gross';

  static const String platformFeesKey_ = r'platform_fees';

  static const String proRawwKey_ = r'pro_raww';

  static const String clientRawwKey_ = r'client_raww';

  static const String proCashKey_ = r'pro_cash';

  static const String averageGrossKey_ = r'average_gross';

  static const String reconstructedKey_ = r'reconstructed';
}
