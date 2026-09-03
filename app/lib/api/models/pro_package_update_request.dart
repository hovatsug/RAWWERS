/// ProPackageUpdateRequest
/// {
///     "properties": {
///         "title": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
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
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
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
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Price"
///         },
///         "currency": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Currency"
///         },
///         "included_photos": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
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
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Extra Photo Price"
///         },
///         "proofs_sla_days": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Proofs Sla Days"
///         },
///         "finals_sla_days": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Finals Sla Days"
///         },
///         "addons": {
///             "anyOf": [
///                 {
///                     "type": "array",
///                     "items": {
///                         "type": "object"
///                     }
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Addons"
///         },
///         "is_active": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Is Active"
///         }
///     },
///     "type": "object",
///     "title": "ProPackageUpdateRequest"
/// }
library pro_package_update_request;

import 'exports.dart';
part 'pro_package_update_request.freezed.dart';
part 'pro_package_update_request.g.dart'; // ProPackageUpdateRequest

@freezed
abstract class ProPackageUpdateRequest with _$ProPackageUpdateRequest {
  const ProPackageUpdateRequest._();

  @jsonSerializable
  const factory ProPackageUpdateRequest({
    /// title
    @JsonKey(name: ProPackageUpdateRequest.titleKey_) String? title,

    /// nicheId
    @JsonKey(name: ProPackageUpdateRequest.nicheIdKey_) String? nicheId,

    /// nicheSlug
    @JsonKey(name: ProPackageUpdateRequest.nicheSlugKey_) String? nicheSlug,

    /// description
    @JsonKey(name: ProPackageUpdateRequest.descriptionKey_) String? description,

    /// durationMinutes
    @JsonKey(name: ProPackageUpdateRequest.durationMinutesKey_)
    int? durationMinutes,

    /// price
    @JsonKey(name: ProPackageUpdateRequest.priceKey_) dynamic? price,

    /// currency
    @JsonKey(name: ProPackageUpdateRequest.currencyKey_) String? currency,

    /// includedPhotos
    @JsonKey(name: ProPackageUpdateRequest.includedPhotosKey_)
    int? includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: ProPackageUpdateRequest.extraPhotoPriceKey_)
    dynamic? extraPhotoPrice,

    /// proofsSlaDays
    @JsonKey(name: ProPackageUpdateRequest.proofsSlaDaysKey_)
    int? proofsSlaDays,

    /// finalsSlaDays
    @JsonKey(name: ProPackageUpdateRequest.finalsSlaDaysKey_)
    int? finalsSlaDays,

    /// addons
    @JsonKey(name: ProPackageUpdateRequest.addonsKey_)
    List<Map<String, dynamic>>? addons,

    /// isActive
    @JsonKey(name: ProPackageUpdateRequest.isActiveKey_) bool? isActive,
  }) = _ProPackageUpdateRequest;

  factory ProPackageUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProPackageUpdateRequestFromJson(json);

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

  static const String isActiveKey_ = r'is_active';
}
