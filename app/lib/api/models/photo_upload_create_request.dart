/// PhotoUploadCreateRequest
/// {
///     "properties": {
///         "purpose": {
///             "$ref": "#/components/schemas/MediaPurpose"
///         },
///         "content_type": {
///             "type": "string",
///             "title": "Content Type"
///         },
///         "file_name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "File Name"
///         },
///         "visibility": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/MediaVisibility"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "gallery_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gallery Id"
///         },
///         "sha256": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^[0-9a-fA-F]{64}$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Sha256"
///         }
///     },
///     "type": "object",
///     "required": [
///         "purpose",
///         "content_type"
///     ],
///     "title": "PhotoUploadCreateRequest"
/// }
library photo_upload_create_request;

import 'exports.dart';
part 'photo_upload_create_request.freezed.dart';
part 'photo_upload_create_request.g.dart'; // PhotoUploadCreateRequest

@freezed
abstract class PhotoUploadCreateRequest with _$PhotoUploadCreateRequest {
  const PhotoUploadCreateRequest._();

  @jsonSerializable
  const factory PhotoUploadCreateRequest({
    /// purpose
    @JsonKey(name: PhotoUploadCreateRequest.purposeKey_)
    required MediaPurpose purpose,

    /// contentType
    @JsonKey(name: PhotoUploadCreateRequest.contentTypeKey_)
    required String contentType,

    /// fileName
    @JsonKey(name: PhotoUploadCreateRequest.fileNameKey_) String? fileName,

    /// visibility
    @JsonKey(name: PhotoUploadCreateRequest.visibilityKey_)
    MediaVisibility? visibility,

    /// galleryId
    @JsonKey(name: PhotoUploadCreateRequest.galleryIdKey_) String? galleryId,

    /// sha256
    @JsonKey(name: PhotoUploadCreateRequest.sha256Key_) String? sha256,
  }) = _PhotoUploadCreateRequest;

  factory PhotoUploadCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadCreateRequestFromJson(json);

  static const String purposeKey_ = r'purpose';

  static const String contentTypeKey_ = r'content_type';

  static const String fileNameKey_ = r'file_name';

  static const String visibilityKey_ = r'visibility';

  static const String galleryIdKey_ = r'gallery_id';

  static const String sha256Key_ = r'sha256';
}
