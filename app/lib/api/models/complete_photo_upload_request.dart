/// CompletePhotoUploadRequest
/// {
///     "properties": {
///         "byte_size": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Byte Size"
///         }
///     },
///     "type": "object",
///     "title": "CompletePhotoUploadRequest"
/// }
library complete_photo_upload_request;

import 'exports.dart';
part 'complete_photo_upload_request.freezed.dart';
part 'complete_photo_upload_request.g.dart'; // CompletePhotoUploadRequest

@freezed
abstract class CompletePhotoUploadRequest with _$CompletePhotoUploadRequest {
  const CompletePhotoUploadRequest._();

  @jsonSerializable
  const factory CompletePhotoUploadRequest({
    /// byteSize
    @JsonKey(name: CompletePhotoUploadRequest.byteSizeKey_) int? byteSize,
  }) = _CompletePhotoUploadRequest;

  factory CompletePhotoUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$CompletePhotoUploadRequestFromJson(json);

  static const String byteSizeKey_ = r'byte_size';
}
