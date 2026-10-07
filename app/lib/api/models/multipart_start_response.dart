/// MultipartStartResponse
/// {
///     "properties": {
///         "part_size": {
///             "type": "integer",
///             "title": "Part Size"
///         },
///         "part_count": {
///             "type": "integer",
///             "title": "Part Count"
///         }
///     },
///     "type": "object",
///     "required": [
///         "part_size",
///         "part_count"
///     ],
///     "title": "MultipartStartResponse"
/// }
library multipart_start_response;

import 'exports.dart';
part 'multipart_start_response.freezed.dart';
part 'multipart_start_response.g.dart'; // MultipartStartResponse

@freezed
abstract class MultipartStartResponse with _$MultipartStartResponse {
  const MultipartStartResponse._();

  @jsonSerializable
  const factory MultipartStartResponse({
    /// partSize
    @JsonKey(name: MultipartStartResponse.partSizeKey_) required int partSize,

    /// partCount
    @JsonKey(name: MultipartStartResponse.partCountKey_) required int partCount,
  }) = _MultipartStartResponse;

  factory MultipartStartResponse.fromJson(Map<String, dynamic> json) =>
      _$MultipartStartResponseFromJson(json);

  static const String partSizeKey_ = r'part_size';

  static const String partCountKey_ = r'part_count';
}
