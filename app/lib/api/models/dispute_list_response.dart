/// DisputeListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/DisputeDetailView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "DisputeListResponse"
/// }
library dispute_list_response;

import 'exports.dart';
part 'dispute_list_response.freezed.dart';
part 'dispute_list_response.g.dart'; // DisputeListResponse

@freezed
abstract class DisputeListResponse with _$DisputeListResponse {
  const DisputeListResponse._();

  @jsonSerializable
  const factory DisputeListResponse({
    /// items
    @JsonKey(name: DisputeListResponse.itemsKey_)
    List<DisputeDetailView>? items,
  }) = _DisputeListResponse;

  factory DisputeListResponse.fromJson(Map<String, dynamic> json) =>
      _$DisputeListResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
