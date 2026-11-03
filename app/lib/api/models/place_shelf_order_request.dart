/// PlaceShelfOrderRequest
/// {
///     "properties": {
///         "item_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Item Id"
///         },
///         "client_request_id": {
///             "type": "string",
///             "title": "Client Request Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "item_id",
///         "client_request_id"
///     ],
///     "title": "PlaceShelfOrderRequest"
/// }
library place_shelf_order_request;

import 'exports.dart';
part 'place_shelf_order_request.freezed.dart';
part 'place_shelf_order_request.g.dart'; // PlaceShelfOrderRequest

@freezed
abstract class PlaceShelfOrderRequest with _$PlaceShelfOrderRequest {
  const PlaceShelfOrderRequest._();

  @jsonSerializable
  const factory PlaceShelfOrderRequest({
    /// itemId
    @JsonKey(name: PlaceShelfOrderRequest.itemIdKey_) required String itemId,

    /// clientRequestId
    @JsonKey(name: PlaceShelfOrderRequest.clientRequestIdKey_)
    required String clientRequestId,
  }) = _PlaceShelfOrderRequest;

  factory PlaceShelfOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$PlaceShelfOrderRequestFromJson(json);

  static const String itemIdKey_ = r'item_id';

  static const String clientRequestIdKey_ = r'client_request_id';
}
