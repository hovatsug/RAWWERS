/// MuxPayload
/// {
///     "properties": {
///         "direct_upload_id": {
///             "type": "string",
///             "title": "Direct Upload Id"
///         },
///         "upload_url": {
///             "type": "string",
///             "title": "Upload Url"
///         },
///         "expires_in": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "direct_upload_id",
///         "upload_url"
///     ],
///     "title": "MuxPayload"
/// }
library mux_payload;

import 'exports.dart';
part 'mux_payload.freezed.dart';
part 'mux_payload.g.dart'; // MuxPayload

@freezed
abstract class MuxPayload with _$MuxPayload {
  const MuxPayload._();

  @jsonSerializable
  const factory MuxPayload({
    /// directUploadId
    @JsonKey(name: MuxPayload.directUploadIdKey_)
    required String directUploadId,

    /// uploadUrl
    @JsonKey(name: MuxPayload.uploadUrlKey_) required String uploadUrl,

    /// expiresIn
    @JsonKey(name: MuxPayload.expiresInKey_) int? expiresIn,
  }) = _MuxPayload;

  factory MuxPayload.fromJson(Map<String, dynamic> json) =>
      _$MuxPayloadFromJson(json);

  static const String directUploadIdKey_ = r'direct_upload_id';

  static const String uploadUrlKey_ = r'upload_url';

  static const String expiresInKey_ = r'expires_in';
}
