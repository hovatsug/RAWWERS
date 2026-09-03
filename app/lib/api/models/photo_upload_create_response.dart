/// PhotoUploadCreateResponse
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "upload": {
///             "$ref": "#/components/schemas/UploadPayload"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "upload"
///     ],
///     "title": "PhotoUploadCreateResponse"
/// }
library photo_upload_create_response;

import 'exports.dart';
part 'photo_upload_create_response.freezed.dart';
part 'photo_upload_create_response.g.dart'; // PhotoUploadCreateResponse

@freezed
abstract class PhotoUploadCreateResponse with _$PhotoUploadCreateResponse {
  const PhotoUploadCreateResponse._();

  @jsonSerializable
  const factory PhotoUploadCreateResponse({
    /// mediaAssetId
    @JsonKey(name: PhotoUploadCreateResponse.mediaAssetIdKey_)
    required String mediaAssetId,

    /// upload
    @JsonKey(name: PhotoUploadCreateResponse.uploadKey_)
    required UploadPayload upload,
  }) = _PhotoUploadCreateResponse;

  factory PhotoUploadCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadCreateResponseFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String uploadKey_ = r'upload';
}
