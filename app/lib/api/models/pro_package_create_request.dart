/// ProPackageCreateRequest
/// {
///     "properties": {
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "niche_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Niche Id"
///         },
///         "niche_slug": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Niche Slug"
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
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 }
///             ],
///             "title": "Price"
///         },
///         "currency": {
///             "type": "string",
///             "default": "EUR",
///             "title": "Currency"
///         },
///         "included_photos": {
///             "type": "integer",
///             "title": "Included Photos"
///         },
///         "extra_photo_price": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 }
///             ],
///             "title": "Extra Photo Price"
///         },
///         "proofs_sla_days": {
///             "type": "integer",
///             "default": 3,
///             "title": "Proofs Sla Days"
///         },
///         "finals_sla_days": {
///             "type": "integer",
///             "default": 7,
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
///         "title",
///         "duration_minutes",
///         "price",
///         "included_photos",
///         "extra_photo_price"
///     ],
///     "title": "ProPackageCreateRequest"
/// }
library pro_package_create_request;

import 'exports.dart';
part 'pro_package_create_request.freezed.dart';
part 'pro_package_create_request.g.dart'; // ProPackageCreateRequest

@freezed
abstract class ProPackageCreateRequest with _$ProPackageCreateRequest {
  const ProPackageCreateRequest._();

  @jsonSerializable
  const factory ProPackageCreateRequest({
    /// title
    @JsonKey(name: ProPackageCreateRequest.titleKey_) required String title,

    /// nicheId
    @JsonKey(name: ProPackageCreateRequest.nicheIdKey_) String? nicheId,

    /// nicheSlug
    @JsonKey(name: ProPackageCreateRequest.nicheSlugKey_) String? nicheSlug,

    /// description
    @JsonKey(name: ProPackageCreateRequest.descriptionKey_) String? description,

    /// durationMinutes
    @JsonKey(name: ProPackageCreateRequest.durationMinutesKey_)
    required int durationMinutes,

    /// price
    @JsonKey(name: ProPackageCreateRequest.priceKey_) required dynamic price,

    /// currency
    @Default('EUR')
    @JsonKey(name: ProPackageCreateRequest.currencyKey_)
    String currency,

    /// includedPhotos
    @JsonKey(name: ProPackageCreateRequest.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: ProPackageCreateRequest.extraPhotoPriceKey_)
    required dynamic extraPhotoPrice,

    /// proofsSlaDays
    @Default(3)
    @JsonKey(name: ProPackageCreateRequest.proofsSlaDaysKey_)
    int proofsSlaDays,

    /// finalsSlaDays
    @Default(7)
    @JsonKey(name: ProPackageCreateRequest.finalsSlaDaysKey_)
    int finalsSlaDays,

    /// addons
    @JsonKey(name: ProPackageCreateRequest.addonsKey_)
    List<Map<String, dynamic>>? addons,
  }) = _ProPackageCreateRequest;

  factory ProPackageCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProPackageCreateRequestFromJson(json);

  static const String titleKey_ = r'title';

  static const String nicheIdKey_ = r'niche_id';

  static const String nicheSlugKey_ = r'niche_slug';

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
