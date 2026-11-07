/// BookingCreditPreview
/// {
///     "properties": {
///         "balance_eur": {
///             "type": "string",
///             "title": "Balance Eur"
///         },
///         "discount_eur": {
///             "type": "string",
///             "title": "Discount Eur"
///         },
///         "price_eur": {
///             "type": "string",
///             "title": "Price Eur"
///         },
///         "total_eur": {
///             "type": "string",
///             "title": "Total Eur"
///         },
///         "max_discount_percent": {
///             "type": "integer",
///             "title": "Max Discount Percent"
///         },
///         "applied": {
///             "type": "boolean",
///             "title": "Applied"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "balance_eur",
///         "discount_eur",
///         "price_eur",
///         "total_eur",
///         "max_discount_percent",
///         "applied",
///         "currency"
///     ],
///     "title": "BookingCreditPreview"
/// }
library booking_credit_preview;

import 'exports.dart';
part 'booking_credit_preview.freezed.dart';
part 'booking_credit_preview.g.dart'; // BookingCreditPreview

@freezed
abstract class BookingCreditPreview with _$BookingCreditPreview {
  const BookingCreditPreview._();

  @jsonSerializable
  const factory BookingCreditPreview({
    /// balanceEur
    @JsonKey(name: BookingCreditPreview.balanceEurKey_)
    required String balanceEur,

    /// discountEur
    @JsonKey(name: BookingCreditPreview.discountEurKey_)
    required String discountEur,

    /// priceEur
    @JsonKey(name: BookingCreditPreview.priceEurKey_) required String priceEur,

    /// totalEur
    @JsonKey(name: BookingCreditPreview.totalEurKey_) required String totalEur,

    /// maxDiscountPercent
    @JsonKey(name: BookingCreditPreview.maxDiscountPercentKey_)
    required int maxDiscountPercent,

    /// applied
    @JsonKey(name: BookingCreditPreview.appliedKey_) required bool applied,

    /// currency
    @JsonKey(name: BookingCreditPreview.currencyKey_) required String currency,
  }) = _BookingCreditPreview;

  factory BookingCreditPreview.fromJson(Map<String, dynamic> json) =>
      _$BookingCreditPreviewFromJson(json);

  static const String balanceEurKey_ = r'balance_eur';

  static const String discountEurKey_ = r'discount_eur';

  static const String priceEurKey_ = r'price_eur';

  static const String totalEurKey_ = r'total_eur';

  static const String maxDiscountPercentKey_ = r'max_discount_percent';

  static const String appliedKey_ = r'applied';

  static const String currencyKey_ = r'currency';
}
