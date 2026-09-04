/// ProExtraImagePriceResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProExtraImagePriceRow"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "ProExtraImagePriceResponse"
/// }
library pro_extra_image_price_response;

import 'exports.dart';
part 'pro_extra_image_price_response.freezed.dart';
part 'pro_extra_image_price_response.g.dart'; // ProExtraImagePriceResponse

@freezed
abstract class ProExtraImagePriceResponse with _$ProExtraImagePriceResponse {
  const ProExtraImagePriceResponse._();

  @jsonSerializable
  const factory ProExtraImagePriceResponse({
    /// items
    @JsonKey(name: ProExtraImagePriceResponse.itemsKey_)
    List<ProExtraImagePriceRow>? items,
  }) = _ProExtraImagePriceResponse;

  factory ProExtraImagePriceResponse.fromJson(Map<String, dynamic> json) =>
      _$ProExtraImagePriceResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
