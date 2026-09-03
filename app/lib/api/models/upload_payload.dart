/// UploadPayload
/// {
///     "properties": {
///         "method": {
///             "type": "string",
///             "title": "Method"
///         },
///         "url": {
///             "type": "string",
///             "title": "Url"
///         },
///         "headers": {
///             "type": "object",
///             "title": "Headers"
///         },
///         "storage_key": {
///             "type": "string",
///             "title": "Storage Key"
///         },
///         "expires_in": {
///             "type": "integer",
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "method",
///         "url",
///         "storage_key",
///         "expires_in"
///     ],
///     "title": "UploadPayload"
/// }
library upload_payload;

import 'exports.dart';
part 'upload_payload.freezed.dart';
part 'upload_payload.g.dart'; // UploadPayload

@freezed
abstract class UploadPayload with _$UploadPayload {
  const UploadPayload._();

  @jsonSerializable
  const factory UploadPayload({
    /// method
    @JsonKey(name: UploadPayload.methodKey_) required String method,

    /// url
    @JsonKey(name: UploadPayload.urlKey_) required String url,

    /// headers
    @JsonKey(name: UploadPayload.headersKey_) Map<String, dynamic>? headers,

    /// storageKey
    @JsonKey(name: UploadPayload.storageKeyKey_) required String storageKey,

    /// expiresIn
    @JsonKey(name: UploadPayload.expiresInKey_) required int expiresIn,
  }) = _UploadPayload;

  factory UploadPayload.fromJson(Map<String, dynamic> json) =>
      _$UploadPayloadFromJson(json);

  static const String methodKey_ = r'method';

  static const String urlKey_ = r'url';

  static const String headersKey_ = r'headers';

  static const String storageKeyKey_ = r'storage_key';

  static const String expiresInKey_ = r'expires_in';
}
