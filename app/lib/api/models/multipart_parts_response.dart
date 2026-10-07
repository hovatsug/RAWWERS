/// MultipartPartsResponse
/// {
///     "properties": {
///         "part_size": {
///             "type": "integer",
///             "title": "Part Size"
///         },
///         "part_count": {
///             "type": "integer",
///             "title": "Part Count"
///         },
///         "parts": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MultipartPartView"
///             },
///             "title": "Parts"
///         }
///     },
///     "type": "object",
///     "required": [
///         "part_size",
///         "part_count",
///         "parts"
///     ],
///     "title": "MultipartPartsResponse",
///     "description": "What R2 already holds: the parts a resumed upload can skip."
/// }
library multipart_parts_response;

import 'exports.dart';
part 'multipart_parts_response.freezed.dart';
part 'multipart_parts_response.g.dart'; // MultipartPartsResponse

@freezed
abstract class MultipartPartsResponse with _$MultipartPartsResponse {
  const MultipartPartsResponse._();

  @jsonSerializable
  const factory MultipartPartsResponse({
    /// partSize
    @JsonKey(name: MultipartPartsResponse.partSizeKey_) required int partSize,

    /// partCount
    @JsonKey(name: MultipartPartsResponse.partCountKey_) required int partCount,

    /// parts
    @JsonKey(name: MultipartPartsResponse.partsKey_)
    required List<MultipartPartView> parts,
  }) = _MultipartPartsResponse;

  factory MultipartPartsResponse.fromJson(Map<String, dynamic> json) =>
      _$MultipartPartsResponseFromJson(json);

  static const String partSizeKey_ = r'part_size';

  static const String partCountKey_ = r'part_count';

  static const String partsKey_ = r'parts';
}
