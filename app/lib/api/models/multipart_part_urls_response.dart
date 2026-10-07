/// MultipartPartUrlsResponse
/// {
///     "properties": {
///         "parts": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MultipartPartUrl"
///             },
///             "title": "Parts"
///         },
///         "expires_in": {
///             "type": "integer",
///             "title": "Expires In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "parts",
///         "expires_in"
///     ],
///     "title": "MultipartPartUrlsResponse"
/// }
library multipart_part_urls_response;

import 'exports.dart';
part 'multipart_part_urls_response.freezed.dart';
part 'multipart_part_urls_response.g.dart'; // MultipartPartUrlsResponse

@freezed
abstract class MultipartPartUrlsResponse with _$MultipartPartUrlsResponse {
  const MultipartPartUrlsResponse._();

  @jsonSerializable
  const factory MultipartPartUrlsResponse({
    /// parts
    @JsonKey(name: MultipartPartUrlsResponse.partsKey_)
    required List<MultipartPartUrl> parts,

    /// expiresIn
    @JsonKey(name: MultipartPartUrlsResponse.expiresInKey_)
    required int expiresIn,
  }) = _MultipartPartUrlsResponse;

  factory MultipartPartUrlsResponse.fromJson(Map<String, dynamic> json) =>
      _$MultipartPartUrlsResponseFromJson(json);

  static const String partsKey_ = r'parts';

  static const String expiresInKey_ = r'expires_in';
}
