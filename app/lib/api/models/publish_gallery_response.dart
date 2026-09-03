/// PublishGalleryResponse
/// {
///     "properties": {
///         "ok": {
///             "type": "boolean",
///             "title": "Ok"
///         },
///         "status": {
///             "$ref": "#/components/schemas/ProofGalleryStatus"
///         }
///     },
///     "type": "object",
///     "required": [
///         "ok",
///         "status"
///     ],
///     "title": "PublishGalleryResponse"
/// }
library publish_gallery_response;

import 'exports.dart';
part 'publish_gallery_response.freezed.dart';
part 'publish_gallery_response.g.dart'; // PublishGalleryResponse

@freezed
abstract class PublishGalleryResponse with _$PublishGalleryResponse {
  const PublishGalleryResponse._();

  @jsonSerializable
  const factory PublishGalleryResponse({
    /// ok
    @JsonKey(name: PublishGalleryResponse.okKey_) required bool ok,

    /// status
    @JsonKey(name: PublishGalleryResponse.statusKey_)
    required ProofGalleryStatus status,
  }) = _PublishGalleryResponse;

  factory PublishGalleryResponse.fromJson(Map<String, dynamic> json) =>
      _$PublishGalleryResponseFromJson(json);

  static const String okKey_ = r'ok';

  static const String statusKey_ = r'status';
}
