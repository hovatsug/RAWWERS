/// PublicProPackageView
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
///         "duration_minutes": {
///             "type": "integer",
///             "title": "Duration Minutes"
///         },
///         "price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "included_photos": {
///             "type": "integer",
///             "title": "Included Photos"
///         },
///         "extra_photo_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Extra Photo Price"
///         },
///         "proofs_sla_days": {
///             "type": "integer",
///             "title": "Proofs Sla Days"
///         },
///         "finals_sla_days": {
///             "type": "integer",
///             "title": "Finals Sla Days"
///         },
///         "addons": {
///             "type": "array",
///             "items": {
///                 "type": "object"
///             },
///             "title": "Addons"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "title",
///         "duration_minutes",
///         "price",
///         "currency",
///         "included_photos",
///         "extra_photo_price",
///         "proofs_sla_days",
///         "finals_sla_days",
///         "addons"
///     ],
///     "title": "PublicProPackageView"
/// }
library public_pro_package_view;

import 'exports.dart';
part 'public_pro_package_view.freezed.dart';
part 'public_pro_package_view.g.dart'; // PublicProPackageView

@freezed
abstract class PublicProPackageView with _$PublicProPackageView {
  const PublicProPackageView._();

  @jsonSerializable
  const factory PublicProPackageView({
    /// id
    @JsonKey(name: PublicProPackageView.idKey_) required String id,

    /// title
    @JsonKey(name: PublicProPackageView.titleKey_) required String title,

    /// description
    @JsonKey(name: PublicProPackageView.descriptionKey_) String? description,

    /// durationMinutes
    @JsonKey(name: PublicProPackageView.durationMinutesKey_)
    required int durationMinutes,

    /// price
    @JsonKey(name: PublicProPackageView.priceKey_) required String price,

    /// currency
    @JsonKey(name: PublicProPackageView.currencyKey_) required String currency,

    /// includedPhotos
    @JsonKey(name: PublicProPackageView.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: PublicProPackageView.extraPhotoPriceKey_)
    required String extraPhotoPrice,

    /// proofsSlaDays
    @JsonKey(name: PublicProPackageView.proofsSlaDaysKey_)
    required int proofsSlaDays,

    /// finalsSlaDays
    @JsonKey(name: PublicProPackageView.finalsSlaDaysKey_)
    required int finalsSlaDays,

    /// addons
    @JsonKey(name: PublicProPackageView.addonsKey_)
    required List<Map<String, dynamic>> addons,
  }) = _PublicProPackageView;

  factory PublicProPackageView.fromJson(Map<String, dynamic> json) =>
      _$PublicProPackageViewFromJson(json);

  static const String idKey_ = r'id';

  static const String titleKey_ = r'title';

  static const String descriptionKey_ = r'description';

  static const String durationMinutesKey_ = r'duration_minutes';

  static const String priceKey_ = r'price';

  static const String currencyKey_ = r'currency';

  static const String includedPhotosKey_ = r'included_photos';

  static const String extraPhotoPriceKey_ = r'extra_photo_price';

  static const String proofsSlaDaysKey_ = r'proofs_sla_days';

  static const String finalsSlaDaysKey_ = r'finals_sla_days';

  static const String addonsKey_ = r'addons';
}
