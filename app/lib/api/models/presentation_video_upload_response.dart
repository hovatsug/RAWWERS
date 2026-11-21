/// PresentationVideoUploadResponse
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "upload_url": {
///             "type": "string",
///             "title": "Upload Url"
///         },
///         "status": {
///             "type": "string",
///             "title": "Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "upload_url",
///         "status"
///     ],
///     "title": "PresentationVideoUploadResponse"
/// }
library presentation_video_upload_response;

import 'exports.dart';
part 'presentation_video_upload_response.freezed.dart';
part 'presentation_video_upload_response.g.dart'; // PresentationVideoUploadResponse

@freezed
abstract class PresentationVideoUploadResponse
    with _$PresentationVideoUploadResponse {
  const PresentationVideoUploadResponse._();

  @jsonSerializable
  const factory PresentationVideoUploadResponse({
    /// mediaAssetId
    @JsonKey(name: PresentationVideoUploadResponse.mediaAssetIdKey_)
    required String mediaAssetId,

    /// uploadUrl
    @JsonKey(name: PresentationVideoUploadResponse.uploadUrlKey_)
    required String uploadUrl,

    /// status
    @JsonKey(name: PresentationVideoUploadResponse.statusKey_)
    required String status,
  }) = _PresentationVideoUploadResponse;

  factory PresentationVideoUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$PresentationVideoUploadResponseFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String uploadUrlKey_ = r'upload_url';

  static const String statusKey_ = r'status';
}
