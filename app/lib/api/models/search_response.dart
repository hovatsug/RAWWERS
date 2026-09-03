/// SearchResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Items"
///         },
///         "used_fallback": {
///             "type": "boolean",
///             "default": false,
///             "title": "Used Fallback"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total",
///         "items"
///     ],
///     "title": "SearchResponse"
/// }
library search_response;

import 'exports.dart';
part 'search_response.freezed.dart';
part 'search_response.g.dart'; // SearchResponse

@freezed
abstract class SearchResponse with _$SearchResponse {
  const SearchResponse._();

  @jsonSerializable
  const factory SearchResponse({
    /// total
    @JsonKey(name: SearchResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: SearchResponse.itemsKey_)
    required List<Map<String, dynamic>> items,

    /// usedFallback
    @Default(false)
    @JsonKey(name: SearchResponse.usedFallbackKey_)
    bool usedFallback,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';

  static const String usedFallbackKey_ = r'used_fallback';
}
