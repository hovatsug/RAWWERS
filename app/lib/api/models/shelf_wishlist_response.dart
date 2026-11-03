/// ShelfWishlistResponse
/// {
///     "properties": {
///         "item_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Item Ids"
///         },
///         "limit": {
///             "type": "integer",
///             "title": "Limit"
///         }
///     },
///     "type": "object",
///     "required": [
///         "item_ids",
///         "limit"
///     ],
///     "title": "ShelfWishlistResponse"
/// }
library shelf_wishlist_response;

import 'exports.dart';
part 'shelf_wishlist_response.freezed.dart';
part 'shelf_wishlist_response.g.dart'; // ShelfWishlistResponse

@freezed
abstract class ShelfWishlistResponse with _$ShelfWishlistResponse {
  const ShelfWishlistResponse._();

  @jsonSerializable
  const factory ShelfWishlistResponse({
    /// itemIds
    @JsonKey(name: ShelfWishlistResponse.itemIdsKey_)
    required List<String> itemIds,

    /// limit
    @JsonKey(name: ShelfWishlistResponse.limitKey_) required int limit,
  }) = _ShelfWishlistResponse;

  factory ShelfWishlistResponse.fromJson(Map<String, dynamic> json) =>
      _$ShelfWishlistResponseFromJson(json);

  static const String itemIdsKey_ = r'item_ids';

  static const String limitKey_ = r'limit';
}
