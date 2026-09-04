/// ProExtraImagePriceUpdateRequest
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProExtraImagePriceItem"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "ProExtraImagePriceUpdateRequest"
/// }
library pro_extra_image_price_update_request;

import 'exports.dart';
part 'pro_extra_image_price_update_request.freezed.dart';
part 'pro_extra_image_price_update_request.g.dart'; // ProExtraImagePriceUpdateRequest

@freezed
abstract class ProExtraImagePriceUpdateRequest
    with _$ProExtraImagePriceUpdateRequest {
  const ProExtraImagePriceUpdateRequest._();

  @jsonSerializable
  const factory ProExtraImagePriceUpdateRequest({
    /// items
    @JsonKey(name: ProExtraImagePriceUpdateRequest.itemsKey_)
    List<ProExtraImagePriceItem>? items,
  }) = _ProExtraImagePriceUpdateRequest;

  factory ProExtraImagePriceUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProExtraImagePriceUpdateRequestFromJson(json);

  static const String itemsKey_ = r'items';
}
