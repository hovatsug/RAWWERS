/// ShelfOrdersResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ShelfOrderView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items"
///     ],
///     "title": "ShelfOrdersResponse"
/// }
library shelf_orders_response;

import 'exports.dart';
part 'shelf_orders_response.freezed.dart';
part 'shelf_orders_response.g.dart'; // ShelfOrdersResponse

@freezed
abstract class ShelfOrdersResponse with _$ShelfOrdersResponse {
  const ShelfOrdersResponse._();

  @jsonSerializable
  const factory ShelfOrdersResponse({
    /// items
    @JsonKey(name: ShelfOrdersResponse.itemsKey_)
    required List<ShelfOrderView> items,
  }) = _ShelfOrdersResponse;

  factory ShelfOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$ShelfOrdersResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
