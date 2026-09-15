/// GigInvoiceView
/// {
///     "properties": {
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "issued_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Issued At"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "client_total": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Client Total"
///         },
///         "platform_retained": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Platform Retained"
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
///         "retained_percent": {
///             "type": "integer",
///             "title": "Retained Percent"
///         },
///         "pro_raww_percent": {
///             "type": "integer",
///             "title": "Pro Raww Percent"
///         },
///         "client_credit_percent": {
///             "type": "integer",
///             "title": "Client Credit Percent"
///         },
///         "photos_delivered": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Photos Delivered"
///         },
///         "rates_were_stamped": {
///             "type": "boolean",
///             "default": true,
///             "title": "Rates Were Stamped"
///         },
///         "vat_status": {
///             "type": "string",
///             "default": "not_answered",
///             "title": "Vat Status"
///         },
///         "vat_rate_percent": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Rate Percent"
///         },
///         "vat_number": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Number"
///         },
///         "vat_net_amount": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Net Amount"
///         },
///         "vat_amount": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Vat Amount"
///         },
///         "platform_commission_vat": {
///             "type": "null",
///             "title": "Platform Commission Vat"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig_id",
///         "issued_at",
///         "currency",
///         "client_total",
///         "platform_retained",
///         "pro_raww",
///         "client_raww",
///         "pro_cash",
///         "retained_percent",
///         "pro_raww_percent",
///         "client_credit_percent"
///     ],
///     "title": "GigInvoiceView",
///     "description": "One completed gig, line by line.\n\nEvery figure is computed server-side from the gig's own record. The app\nrenders these and adds nothing up itself - the same rule the pricing curve\nfollows, and for the same reason: two places doing the same arithmetic is\nhow they end up disagreeing."
/// }
library gig_invoice_view;

import 'exports.dart';
part 'gig_invoice_view.freezed.dart';
part 'gig_invoice_view.g.dart'; // GigInvoiceView

@freezed
abstract class GigInvoiceView with _$GigInvoiceView {
  const GigInvoiceView._();

  @jsonSerializable
  const factory GigInvoiceView({
    /// gigId
    @JsonKey(name: GigInvoiceView.gigIdKey_) required String gigId,

    /// issuedAt
    @JsonKey(name: GigInvoiceView.issuedAtKey_) required DateTime issuedAt,

    /// currency
    @JsonKey(name: GigInvoiceView.currencyKey_) required String currency,

    /// clientTotal
    @JsonKey(name: GigInvoiceView.clientTotalKey_) required String clientTotal,

    /// platformRetained
    @JsonKey(name: GigInvoiceView.platformRetainedKey_)
    required String platformRetained,

    /// proRaww
    @JsonKey(name: GigInvoiceView.proRawwKey_) required String proRaww,

    /// clientRaww
    @JsonKey(name: GigInvoiceView.clientRawwKey_) required String clientRaww,

    /// proCash
    @JsonKey(name: GigInvoiceView.proCashKey_) required String proCash,

    /// retainedPercent
    @JsonKey(name: GigInvoiceView.retainedPercentKey_)
    required int retainedPercent,

    /// proRawwPercent
    @JsonKey(name: GigInvoiceView.proRawwPercentKey_)
    required int proRawwPercent,

    /// clientCreditPercent
    @JsonKey(name: GigInvoiceView.clientCreditPercentKey_)
    required int clientCreditPercent,

    /// photosDelivered
    @JsonKey(name: GigInvoiceView.photosDeliveredKey_) int? photosDelivered,

    /// ratesWereStamped
    @Default(true)
    @JsonKey(name: GigInvoiceView.ratesWereStampedKey_)
    bool ratesWereStamped,

    /// vatStatus
    @Default('not_answered')
    @JsonKey(name: GigInvoiceView.vatStatusKey_)
    String vatStatus,

    /// vatRatePercent
    @JsonKey(name: GigInvoiceView.vatRatePercentKey_) int? vatRatePercent,

    /// vatNumber
    @JsonKey(name: GigInvoiceView.vatNumberKey_) String? vatNumber,

    /// vatNetAmount
    @JsonKey(name: GigInvoiceView.vatNetAmountKey_) String? vatNetAmount,

    /// vatAmount
    @JsonKey(name: GigInvoiceView.vatAmountKey_) String? vatAmount,

    /// platformCommissionVat
    @JsonKey(name: GigInvoiceView.platformCommissionVatKey_)
    dynamic? platformCommissionVat,
  }) = _GigInvoiceView;

  factory GigInvoiceView.fromJson(Map<String, dynamic> json) =>
      _$GigInvoiceViewFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String issuedAtKey_ = r'issued_at';

  static const String currencyKey_ = r'currency';

  static const String clientTotalKey_ = r'client_total';

  static const String platformRetainedKey_ = r'platform_retained';

  static const String proRawwKey_ = r'pro_raww';

  static const String clientRawwKey_ = r'client_raww';

  static const String proCashKey_ = r'pro_cash';

  static const String retainedPercentKey_ = r'retained_percent';

  static const String proRawwPercentKey_ = r'pro_raww_percent';

  static const String clientCreditPercentKey_ = r'client_credit_percent';

  static const String photosDeliveredKey_ = r'photos_delivered';

  static const String ratesWereStampedKey_ = r'rates_were_stamped';

  static const String vatStatusKey_ = r'vat_status';

  static const String vatRatePercentKey_ = r'vat_rate_percent';

  static const String vatNumberKey_ = r'vat_number';

  static const String vatNetAmountKey_ = r'vat_net_amount';

  static const String vatAmountKey_ = r'vat_amount';

  static const String platformCommissionVatKey_ = r'platform_commission_vat';
}
