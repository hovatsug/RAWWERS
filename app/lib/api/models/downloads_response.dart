/// DownloadsResponse
/// {
///     "properties": {
///         "gallery_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gallery Id"
///         },
///         "urls": {
///             "type": "object",
///             "title": "Urls"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gallery_id",
///         "urls"
///     ],
///     "title": "DownloadsResponse"
/// }
library downloads_response;

import 'exports.dart';
part 'downloads_response.freezed.dart';
part 'downloads_response.g.dart'; // DownloadsResponse

@freezed
abstract class DownloadsResponse with _$DownloadsResponse {
  const DownloadsResponse._();

  @jsonSerializable
  const factory DownloadsResponse({
    /// galleryId
    @JsonKey(name: DownloadsResponse.galleryIdKey_) required String galleryId,

    /// urls
    @JsonKey(name: DownloadsResponse.urlsKey_)
    required Map<String, dynamic> urls,
  }) = _DownloadsResponse;

  factory DownloadsResponse.fromJson(Map<String, dynamic> json) =>
      _$DownloadsResponseFromJson(json);

  static const String galleryIdKey_ = r'gallery_id';

  static const String urlsKey_ = r'urls';
}
