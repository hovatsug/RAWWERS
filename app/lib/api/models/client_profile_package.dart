/// ClientProfilePackage
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "niche_slug",
///         "title",
///         "duration_minutes",
///         "price",
///         "currency",
///         "included_photos",
///         "extra_photo_price",
///         "proofs_sla_days",
///         "finals_sla_days"
///     ],
///     "title": "ClientProfilePackage"
/// }
library client_profile_package;

import 'exports.dart';
part 'client_profile_package.freezed.dart';
part 'client_profile_package.g.dart'; // ClientProfilePackage

@freezed
abstract class ClientProfilePackage with _$ClientProfilePackage {
  const ClientProfilePackage._();

  @jsonSerializable
  const factory ClientProfilePackage({
    /// id
    @JsonKey(name: ClientProfilePackage.idKey_) required String id,

    /// nicheSlug
    @JsonKey(name: ClientProfilePackage.nicheSlugKey_)
    required String nicheSlug,

    /// title
    @JsonKey(name: ClientProfilePackage.titleKey_) required String title,

    /// description
    @JsonKey(name: ClientProfilePackage.descriptionKey_) String? description,

    /// durationMinutes
    @JsonKey(name: ClientProfilePackage.durationMinutesKey_)
    required int durationMinutes,

    /// price
    @JsonKey(name: ClientProfilePackage.priceKey_) required String price,

    /// currency
    @JsonKey(name: ClientProfilePackage.currencyKey_) required String currency,

    /// includedPhotos
    @JsonKey(name: ClientProfilePackage.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: ClientProfilePackage.extraPhotoPriceKey_)
    required String extraPhotoPrice,

    /// proofsSlaDays
    @JsonKey(name: ClientProfilePackage.proofsSlaDaysKey_)
    required int proofsSlaDays,

    /// finalsSlaDays
    @JsonKey(name: ClientProfilePackage.finalsSlaDaysKey_)
    required int finalsSlaDays,
  }) = _ClientProfilePackage;

  factory ClientProfilePackage.fromJson(Map<String, dynamic> json) =>
      _$ClientProfilePackageFromJson(json);

  static const String idKey_ = r'id';

  static const String nicheSlugKey_ = r'niche_slug';

  static const String titleKey_ = r'title';

  static const String descriptionKey_ = r'description';

  static const String durationMinutesKey_ = r'duration_minutes';

  static const String priceKey_ = r'price';

  static const String currencyKey_ = r'currency';

  static const String includedPhotosKey_ = r'included_photos';

  static const String extraPhotoPriceKey_ = r'extra_photo_price';

  static const String proofsSlaDaysKey_ = r'proofs_sla_days';

  static const String finalsSlaDaysKey_ = r'finals_sla_days';
}
