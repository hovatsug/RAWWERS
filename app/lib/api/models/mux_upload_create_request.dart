/// MuxUploadCreateRequest
/// {
///     "properties": {
///         "purpose": {
///             "$ref": "#/components/schemas/MediaPurpose"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "purpose"
///     ],
///     "title": "MuxUploadCreateRequest"
/// }
library mux_upload_create_request;

import 'exports.dart';
part 'mux_upload_create_request.freezed.dart';
part 'mux_upload_create_request.g.dart'; // MuxUploadCreateRequest

@freezed
abstract class MuxUploadCreateRequest with _$MuxUploadCreateRequest {
  const MuxUploadCreateRequest._();

  @jsonSerializable
  const factory MuxUploadCreateRequest({
    /// purpose
    @JsonKey(name: MuxUploadCreateRequest.purposeKey_)
    required MediaPurpose purpose,

    /// visibility
    @JsonKey(name: MuxUploadCreateRequest.visibilityKey_)
    MediaVisibility? visibility,
  }) = _MuxUploadCreateRequest;

  factory MuxUploadCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MuxUploadCreateRequestFromJson(json);

  static const String purposeKey_ = r'purpose';

  static const String visibilityKey_ = r'visibility';
}
