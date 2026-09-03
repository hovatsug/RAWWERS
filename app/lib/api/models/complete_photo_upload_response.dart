/// CompletePhotoUploadResponse
/// {
///     "properties": {
///         "ok": {
///             "type": "boolean",
///             "title": "Ok"
///         },
///         "current_status": {
///             "type": "string",
///             "title": "Current Status"
///         }
///     },
///     "type": "object",
///     "required": [
///         "ok",
///         "current_status"
///     ],
///     "title": "CompletePhotoUploadResponse"
/// }
library complete_photo_upload_response;

import 'exports.dart';
part 'complete_photo_upload_response.freezed.dart';
part 'complete_photo_upload_response.g.dart'; // CompletePhotoUploadResponse

@freezed
abstract class CompletePhotoUploadResponse with _$CompletePhotoUploadResponse {
  const CompletePhotoUploadResponse._();

  @jsonSerializable
  const factory CompletePhotoUploadResponse({
    /// ok
    @JsonKey(name: CompletePhotoUploadResponse.okKey_) required bool ok,

    /// currentStatus
    @JsonKey(name: CompletePhotoUploadResponse.currentStatusKey_)
    required String currentStatus,
  }) = _CompletePhotoUploadResponse;

  factory CompletePhotoUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$CompletePhotoUploadResponseFromJson(json);

  static const String okKey_ = r'ok';

  static const String currentStatusKey_ = r'current_status';
}
