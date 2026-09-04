/// ProExtraImagePriceItem
/// {
///     "properties": {
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "unit_price": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 }
///             ],
///             "title": "Unit Price"
///         }
///     },
///     "type": "object",
///     "required": [
///         "niche_slug",
///         "unit_price"
///     ],
///     "title": "ProExtraImagePriceItem"
/// }
library pro_extra_image_price_item;

import 'exports.dart';
part 'pro_extra_image_price_item.freezed.dart';
part 'pro_extra_image_price_item.g.dart'; // ProExtraImagePriceItem

@freezed
abstract class ProExtraImagePriceItem with _$ProExtraImagePriceItem {
  const ProExtraImagePriceItem._();

  @jsonSerializable
  const factory ProExtraImagePriceItem({
    /// nicheSlug
    @JsonKey(name: ProExtraImagePriceItem.nicheSlugKey_)
    required String nicheSlug,

    /// unitPrice
    @JsonKey(name: ProExtraImagePriceItem.unitPriceKey_)
    required dynamic unitPrice,
  }) = _ProExtraImagePriceItem;

  factory ProExtraImagePriceItem.fromJson(Map<String, dynamic> json) =>
      _$ProExtraImagePriceItemFromJson(json);

  static const String nicheSlugKey_ = r'niche_slug';

  static const String unitPriceKey_ = r'unit_price';
}
