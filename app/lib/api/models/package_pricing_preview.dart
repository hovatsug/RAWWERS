/// PackagePricingPreview
/// {
///     "properties": {
///         "package_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Package Id"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "entry_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Entry Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "price_at_photo_count": {
///             "type": "object",
///             "title": "Price At Photo Count"
///         }
///     },
///     "type": "object",
///     "required": [
///         "package_id",
///         "title",
///         "entry_price",
///         "currency",
///         "price_at_photo_count"
///     ],
///     "title": "PackagePricingPreview"
/// }
library package_pricing_preview;

import 'exports.dart';
part 'package_pricing_preview.freezed.dart';
part 'package_pricing_preview.g.dart'; // PackagePricingPreview

@freezed
abstract class PackagePricingPreview with _$PackagePricingPreview {
  const PackagePricingPreview._();

  @jsonSerializable
  const factory PackagePricingPreview({
    /// packageId
    @JsonKey(name: PackagePricingPreview.packageIdKey_)
    required String packageId,

    /// title
    @JsonKey(name: PackagePricingPreview.titleKey_) required String title,

    /// entryPrice
    @JsonKey(name: PackagePricingPreview.entryPriceKey_)
    required String entryPrice,

    /// currency
    @JsonKey(name: PackagePricingPreview.currencyKey_) required String currency,

    /// priceAtPhotoCount
    @JsonKey(name: PackagePricingPreview.priceAtPhotoCountKey_)
    required Map<String, dynamic> priceAtPhotoCount,
  }) = _PackagePricingPreview;

  factory PackagePricingPreview.fromJson(Map<String, dynamic> json) =>
      _$PackagePricingPreviewFromJson(json);

  static const String packageIdKey_ = r'package_id';

  static const String titleKey_ = r'title';

  static const String entryPriceKey_ = r'entry_price';

  static const String currencyKey_ = r'currency';

  static const String priceAtPhotoCountKey_ = r'price_at_photo_count';
}
