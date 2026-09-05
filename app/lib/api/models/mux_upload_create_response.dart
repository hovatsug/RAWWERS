/// MuxUploadCreateResponse
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "mux": {
///             "$ref": "#/components/schemas/MuxPayload"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "mux"
///     ],
///     "title": "MuxUploadCreateResponse"
/// }
library mux_upload_create_response;

import 'exports.dart';
part 'mux_upload_create_response.freezed.dart';
part 'mux_upload_create_response.g.dart'; // MuxUploadCreateResponse

@freezed
abstract class MuxUploadCreateResponse with _$MuxUploadCreateResponse {
  const MuxUploadCreateResponse._();

  @jsonSerializable
  const factory MuxUploadCreateResponse({
    /// mediaAssetId
    @JsonKey(name: MuxUploadCreateResponse.mediaAssetIdKey_)
    required String mediaAssetId,

    /// mux
    @JsonKey(name: MuxUploadCreateResponse.muxKey_) required MuxPayload mux,
  }) = _MuxUploadCreateResponse;

  factory MuxUploadCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$MuxUploadCreateResponseFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String muxKey_ = r'mux';
}
