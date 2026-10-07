/// MultipartPartUrl
/// {
///     "properties": {
///         "part_number": {
///             "type": "integer",
///             "title": "Part Number"
///         },
///         "url": {
///             "type": "string",
///             "title": "Url"
///         }
///     },
///     "type": "object",
///     "required": [
///         "part_number",
///         "url"
///     ],
///     "title": "MultipartPartUrl"
/// }
library multipart_part_url;

import 'exports.dart';
part 'multipart_part_url.freezed.dart';
part 'multipart_part_url.g.dart'; // MultipartPartUrl

@freezed
abstract class MultipartPartUrl with _$MultipartPartUrl {
  const MultipartPartUrl._();

  @jsonSerializable
  const factory MultipartPartUrl({
    /// partNumber
    @JsonKey(name: MultipartPartUrl.partNumberKey_) required int partNumber,

    /// url
    @JsonKey(name: MultipartPartUrl.urlKey_) required String url,
  }) = _MultipartPartUrl;

  factory MultipartPartUrl.fromJson(Map<String, dynamic> json) =>
      _$MultipartPartUrlFromJson(json);

  static const String partNumberKey_ = r'part_number';

  static const String urlKey_ = r'url';
}
