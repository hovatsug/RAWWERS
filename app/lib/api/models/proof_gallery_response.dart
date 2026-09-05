/// ProofGalleryResponse
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
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
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ProofGalleryStatus"
///         },
///         "published_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Published At"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "gig_id",
///         "pro_user_id",
///         "client_user_id",
///         "included_photos",
///         "extra_photo_price",
///         "currency",
///         "status",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ProofGalleryResponse"
/// }
library proof_gallery_response;

import 'exports.dart';
part 'proof_gallery_response.freezed.dart';
part 'proof_gallery_response.g.dart'; // ProofGalleryResponse

@freezed
abstract class ProofGalleryResponse with _$ProofGalleryResponse {
  const ProofGalleryResponse._();

  @jsonSerializable
  const factory ProofGalleryResponse({
    /// id
    @JsonKey(name: ProofGalleryResponse.idKey_) required String id,

    /// gigId
    @JsonKey(name: ProofGalleryResponse.gigIdKey_) required String gigId,

    /// proUserId
    @JsonKey(name: ProofGalleryResponse.proUserIdKey_)
    required String proUserId,

    /// clientUserId
    @JsonKey(name: ProofGalleryResponse.clientUserIdKey_)
    required String clientUserId,

    /// includedPhotos
    @JsonKey(name: ProofGalleryResponse.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: ProofGalleryResponse.extraPhotoPriceKey_)
    required String extraPhotoPrice,

    /// currency
    @JsonKey(name: ProofGalleryResponse.currencyKey_) required String currency,

    /// status
    @JsonKey(name: ProofGalleryResponse.statusKey_)
    required ProofGalleryStatus status,

    /// publishedAt
    @JsonKey(name: ProofGalleryResponse.publishedAtKey_) DateTime? publishedAt,

    /// createdAt
    @JsonKey(name: ProofGalleryResponse.createdAtKey_)
    required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ProofGalleryResponse.updatedAtKey_)
    required DateTime updatedAt,
  }) = _ProofGalleryResponse;

  factory ProofGalleryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProofGalleryResponseFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String includedPhotosKey_ = r'included_photos';

  static const String extraPhotoPriceKey_ = r'extra_photo_price';

  static const String currencyKey_ = r'currency';

  static const String statusKey_ = r'status';

  static const String publishedAtKey_ = r'published_at';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
