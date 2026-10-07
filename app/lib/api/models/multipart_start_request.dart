/// MultipartStartRequest
/// {
///     "properties": {
///         "byte_size": {
///             "type": "integer",
///             "title": "Byte Size"
///         }
///     },
///     "type": "object",
///     "required": [
///         "byte_size"
///     ],
///     "title": "MultipartStartRequest"
/// }
library multipart_start_request;

import 'exports.dart';
part 'multipart_start_request.freezed.dart';
part 'multipart_start_request.g.dart'; // MultipartStartRequest

@freezed
abstract class MultipartStartRequest with _$MultipartStartRequest {
  const MultipartStartRequest._();

  @jsonSerializable
  const factory MultipartStartRequest({
    /// byteSize
    @JsonKey(name: MultipartStartRequest.byteSizeKey_) required int byteSize,
  }) = _MultipartStartRequest;

  factory MultipartStartRequest.fromJson(Map<String, dynamic> json) =>
      _$MultipartStartRequestFromJson(json);

  static const String byteSizeKey_ = r'byte_size';
}
