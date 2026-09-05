/// ClientDiscoverResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientDiscoverCard"
///             },
///             "title": "Items"
///         },
///         "guest_limited": {
///             "type": "boolean",
///             "default": false,
///             "title": "Guest Limited"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total"
///     ],
///     "title": "ClientDiscoverResponse"
/// }
library client_discover_response;

import 'exports.dart';
part 'client_discover_response.freezed.dart';
part 'client_discover_response.g.dart'; // ClientDiscoverResponse

@freezed
abstract class ClientDiscoverResponse with _$ClientDiscoverResponse {
  const ClientDiscoverResponse._();

  @jsonSerializable
  const factory ClientDiscoverResponse({
    /// total
    @JsonKey(name: ClientDiscoverResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: ClientDiscoverResponse.itemsKey_)
    List<ClientDiscoverCard>? items,

    /// guestLimited
    @Default(false)
    @JsonKey(name: ClientDiscoverResponse.guestLimitedKey_)
    bool guestLimited,
  }) = _ClientDiscoverResponse;

  factory ClientDiscoverResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientDiscoverResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';

  static const String guestLimitedKey_ = r'guest_limited';
}
