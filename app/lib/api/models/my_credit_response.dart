/// MyCreditResponse
/// {
///     "properties": {
///         "balance": {
///             "type": "string",
///             "title": "Balance"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "max_discount_percent": {
///             "type": "integer",
///             "title": "Max Discount Percent"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/CreditHistoryItem"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "balance",
///         "currency",
///         "max_discount_percent",
///         "items"
///     ],
///     "title": "MyCreditResponse"
/// }
library my_credit_response;

import 'exports.dart';
part 'my_credit_response.freezed.dart';
part 'my_credit_response.g.dart'; // MyCreditResponse

@freezed
abstract class MyCreditResponse with _$MyCreditResponse {
  const MyCreditResponse._();

  @jsonSerializable
  const factory MyCreditResponse({
    /// balance
    @JsonKey(name: MyCreditResponse.balanceKey_) required String balance,

    /// currency
    @JsonKey(name: MyCreditResponse.currencyKey_) required String currency,

    /// maxDiscountPercent
    @JsonKey(name: MyCreditResponse.maxDiscountPercentKey_)
    required int maxDiscountPercent,

    /// items
    @JsonKey(name: MyCreditResponse.itemsKey_)
    required List<CreditHistoryItem> items,
  }) = _MyCreditResponse;

  factory MyCreditResponse.fromJson(Map<String, dynamic> json) =>
      _$MyCreditResponseFromJson(json);

  static const String balanceKey_ = r'balance';

  static const String currencyKey_ = r'currency';

  static const String maxDiscountPercentKey_ = r'max_discount_percent';

  static const String itemsKey_ = r'items';
}
