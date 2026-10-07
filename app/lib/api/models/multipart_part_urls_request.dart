/// MultipartPartUrlsRequest
/// {
///     "properties": {
///         "part_numbers": {
///             "type": "array",
///             "items": {
///                 "type": "integer"
///             },
///             "title": "Part Numbers"
///         }
///     },
///     "type": "object",
///     "required": [
///         "part_numbers"
///     ],
///     "title": "MultipartPartUrlsRequest"
/// }
library multipart_part_urls_request;

import 'exports.dart';
part 'multipart_part_urls_request.freezed.dart';
part 'multipart_part_urls_request.g.dart'; // MultipartPartUrlsRequest

@freezed
abstract class MultipartPartUrlsRequest with _$MultipartPartUrlsRequest {
  const MultipartPartUrlsRequest._();

  @jsonSerializable
  const factory MultipartPartUrlsRequest({
    /// partNumbers
    @JsonKey(name: MultipartPartUrlsRequest.partNumbersKey_)
    required List<int> partNumbers,
  }) = _MultipartPartUrlsRequest;

  factory MultipartPartUrlsRequest.fromJson(Map<String, dynamic> json) =>
      _$MultipartPartUrlsRequestFromJson(json);

  static const String partNumbersKey_ = r'part_numbers';
}
