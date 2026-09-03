/// PayoutListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/PayoutRequestView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "PayoutListResponse"
/// }
library payout_list_response;

import 'exports.dart';
part 'payout_list_response.freezed.dart';
part 'payout_list_response.g.dart'; // PayoutListResponse

@freezed
abstract class PayoutListResponse with _$PayoutListResponse {
  const PayoutListResponse._();

  @jsonSerializable
  const factory PayoutListResponse({
    /// items
    @JsonKey(name: PayoutListResponse.itemsKey_) List<PayoutRequestView>? items,
  }) = _PayoutListResponse;

  factory PayoutListResponse.fromJson(Map<String, dynamic> json) =>
      _$PayoutListResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
