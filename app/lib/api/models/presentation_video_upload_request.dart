/// PresentationVideoUploadRequest
/// {
///     "properties": {
///         "byte_size": {
///             "type": "integer",
///             "title": "Byte Size"
///         },
///         "duration_seconds": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Duration Seconds"
///         },
///         "content_type": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "maxLength": 64
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Content Type"
///         },
///         "request_id": {
///             "type": "string",
///             "maxLength": 64,
///             "minLength": 8,
///             "pattern": "^[A-Za-z0-9._-]+$",
///             "title": "Request Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "byte_size",
///         "request_id"
///     ],
///     "title": "PresentationVideoUploadRequest",
///     "description": "What the Pro app knows about the chosen video before sending it."
/// }
library presentation_video_upload_request;

import 'exports.dart';
part 'presentation_video_upload_request.freezed.dart';
part 'presentation_video_upload_request.g.dart'; // PresentationVideoUploadRequest

@freezed
abstract class PresentationVideoUploadRequest
    with _$PresentationVideoUploadRequest {
  const PresentationVideoUploadRequest._();

  @jsonSerializable
  const factory PresentationVideoUploadRequest({
    /// byteSize
    @JsonKey(name: PresentationVideoUploadRequest.byteSizeKey_)
    required int byteSize,

    /// durationSeconds
    @JsonKey(name: PresentationVideoUploadRequest.durationSecondsKey_)
    double? durationSeconds,

    /// contentType
    @JsonKey(name: PresentationVideoUploadRequest.contentTypeKey_)
    String? contentType,

    /// requestId
    @JsonKey(name: PresentationVideoUploadRequest.requestIdKey_)
    required String requestId,
  }) = _PresentationVideoUploadRequest;

  factory PresentationVideoUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PresentationVideoUploadRequestFromJson(json);

  static const String byteSizeKey_ = r'byte_size';

  static const String durationSecondsKey_ = r'duration_seconds';

  static const String contentTypeKey_ = r'content_type';

  static const String requestIdKey_ = r'request_id';
}
