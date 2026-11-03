/// RawwHistoryResponse
/// {
///     "properties": {
///         "total": {
///             "type": "integer",
///             "title": "Total"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/RawwEntryView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "total",
///         "items"
///     ],
///     "title": "RawwHistoryResponse"
/// }
library raww_history_response;

import 'exports.dart';
part 'raww_history_response.freezed.dart';
part 'raww_history_response.g.dart'; // RawwHistoryResponse

@freezed
abstract class RawwHistoryResponse with _$RawwHistoryResponse {
  const RawwHistoryResponse._();

  @jsonSerializable
  const factory RawwHistoryResponse({
    /// total
    @JsonKey(name: RawwHistoryResponse.totalKey_) required int total,

    /// items
    @JsonKey(name: RawwHistoryResponse.itemsKey_)
    required List<RawwEntryView> items,
  }) = _RawwHistoryResponse;

  factory RawwHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$RawwHistoryResponseFromJson(json);

  static const String totalKey_ = r'total';

  static const String itemsKey_ = r'items';
}
