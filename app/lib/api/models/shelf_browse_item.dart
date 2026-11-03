/// ShelfBrowseItem
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "brand": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Brand"
///         },
///         "category": {
///             "type": "string",
///             "title": "Category"
///         },
///         "description": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Description"
///         },
///         "image_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Image Url"
///         },
///         "level": {
///             "type": "integer",
///             "title": "Level"
///         },
///         "price_raww": {
///             "type": "integer",
///             "title": "Price Raww"
///         },
///         "in_stock": {
///             "type": "boolean",
///             "title": "In Stock"
///         },
///         "fits_your_gear": {
///             "type": "boolean",
///             "title": "Fits Your Gear"
///         },
///         "wished": {
///             "type": "boolean",
///             "title": "Wished"
///         },
///         "affordable": {
///             "type": "boolean",
///             "title": "Affordable"
///         },
///         "locked": {
///             "type": "boolean",
///             "title": "Locked"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "title",
///         "category",
///         "level",
///         "price_raww",
///         "in_stock",
///         "fits_your_gear",
///         "wished",
///         "affordable",
///         "locked"
///     ],
///     "title": "ShelfBrowseItem"
/// }
library shelf_browse_item;

import 'exports.dart';
part 'shelf_browse_item.freezed.dart';
part 'shelf_browse_item.g.dart'; // ShelfBrowseItem

@freezed
abstract class ShelfBrowseItem with _$ShelfBrowseItem {
  const ShelfBrowseItem._();

  @jsonSerializable
  const factory ShelfBrowseItem({
    /// id
    @JsonKey(name: ShelfBrowseItem.idKey_) required String id,

    /// title
    @JsonKey(name: ShelfBrowseItem.titleKey_) required String title,

    /// brand
    @JsonKey(name: ShelfBrowseItem.brandKey_) String? brand,

    /// category
    @JsonKey(name: ShelfBrowseItem.categoryKey_) required String category,

    /// description
    @JsonKey(name: ShelfBrowseItem.descriptionKey_) String? description,

    /// imageUrl
    @JsonKey(name: ShelfBrowseItem.imageUrlKey_) String? imageUrl,

    /// level
    @JsonKey(name: ShelfBrowseItem.levelKey_) required int level,

    /// priceRaww
    @JsonKey(name: ShelfBrowseItem.priceRawwKey_) required int priceRaww,

    /// inStock
    @JsonKey(name: ShelfBrowseItem.inStockKey_) required bool inStock,

    /// fitsYourGear
    @JsonKey(name: ShelfBrowseItem.fitsYourGearKey_) required bool fitsYourGear,

    /// wished
    @JsonKey(name: ShelfBrowseItem.wishedKey_) required bool wished,

    /// affordable
    @JsonKey(name: ShelfBrowseItem.affordableKey_) required bool affordable,

    /// locked
    @JsonKey(name: ShelfBrowseItem.lockedKey_) required bool locked,
  }) = _ShelfBrowseItem;

  factory ShelfBrowseItem.fromJson(Map<String, dynamic> json) =>
      _$ShelfBrowseItemFromJson(json);

  static const String idKey_ = r'id';

  static const String titleKey_ = r'title';

  static const String brandKey_ = r'brand';

  static const String categoryKey_ = r'category';

  static const String descriptionKey_ = r'description';

  static const String imageUrlKey_ = r'image_url';

  static const String levelKey_ = r'level';

  static const String priceRawwKey_ = r'price_raww';

  static const String inStockKey_ = r'in_stock';

  static const String fitsYourGearKey_ = r'fits_your_gear';

  static const String wishedKey_ = r'wished';

  static const String affordableKey_ = r'affordable';

  static const String lockedKey_ = r'locked';
}
