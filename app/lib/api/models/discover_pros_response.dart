/// DiscoverProsResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProCard"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total",
///         "items"
///     ],
///     "title": "DiscoverProsResponse"
/// }
library discover_pros_response;

import 'exports.dart';
part 'discover_pros_response.freezed.dart';
part 'discover_pros_response.g.dart'; // DiscoverProsResponse

@freezed
abstract class DiscoverProsResponse with _$DiscoverProsResponse {
  const DiscoverProsResponse._();

  @jsonSerializable
  const factory DiscoverProsResponse({
    /// total
    @JsonKey(name: DiscoverProsResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: DiscoverProsResponse.itemsKey_) required List<ProCard> items,
  }) = _DiscoverProsResponse;

  factory DiscoverProsResponse.fromJson(Map<String, dynamic> json) =>
      _$DiscoverProsResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';
}
