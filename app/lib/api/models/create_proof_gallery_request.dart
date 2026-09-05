/// CreateProofGalleryRequest
/// {
///     "properties": {
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "included_photos",
///         "extra_photo_price"
///     ],
///     "title": "CreateProofGalleryRequest"
/// }
library create_proof_gallery_request;

import 'exports.dart';
part 'create_proof_gallery_request.freezed.dart';
part 'create_proof_gallery_request.g.dart'; // CreateProofGalleryRequest

@freezed
abstract class CreateProofGalleryRequest with _$CreateProofGalleryRequest {
  const CreateProofGalleryRequest._();

  @jsonSerializable
  const factory CreateProofGalleryRequest({
    /// includedPhotos
    @JsonKey(name: CreateProofGalleryRequest.includedPhotosKey_)
    required int includedPhotos,

    /// extraPhotoPrice
    @JsonKey(name: CreateProofGalleryRequest.extraPhotoPriceKey_)
    required dynamic extraPhotoPrice,
  }) = _CreateProofGalleryRequest;

  factory CreateProofGalleryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProofGalleryRequestFromJson(json);

  static const String includedPhotosKey_ = r'included_photos';

  static const String extraPhotoPriceKey_ = r'extra_photo_price';
}
