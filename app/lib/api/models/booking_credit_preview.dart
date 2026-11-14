/// BookingCreditPreview
/// {
///     "properties": {
///         "balance": {
///             "type": "string",
///             "title": "Balance"
///         },
///         "credit_currency": {
///             "type": "string",
///             "title": "Credit Currency"
///         },
///         "discount": {
///             "type": "string",
///             "title": "Discount"
///         },
///         "price": {
///             "type": "string",
///             "title": "Price"
///         },
///         "total": {
///             "type": "string",
///             "title": "Total"
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
///         "balance",
///         "credit_currency",
///         "discount",
///         "price",
///         "total",
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
    /// balance
    @JsonKey(name: BookingCreditPreview.balanceKey_) required String balance,

    /// creditCurrency
    @JsonKey(name: BookingCreditPreview.creditCurrencyKey_)
    required String creditCurrency,

    /// discount
    @JsonKey(name: BookingCreditPreview.discountKey_) required String discount,

    /// price
    @JsonKey(name: BookingCreditPreview.priceKey_) required String price,

    /// total
    @JsonKey(name: BookingCreditPreview.totalKey_) required String total,

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

  static const String balanceKey_ = r'balance';

  static const String creditCurrencyKey_ = r'credit_currency';

  static const String discountKey_ = r'discount';

  static const String priceKey_ = r'price';

  static const String totalKey_ = r'total';

  static const String maxDiscountPercentKey_ = r'max_discount_percent';

  static const String appliedKey_ = r'applied';

  static const String currencyKey_ = r'currency';
}
