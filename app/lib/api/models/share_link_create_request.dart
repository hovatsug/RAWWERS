/// ShareLinkCreateRequest
/// {
///     "properties": {
///         "scope": {
///             "$ref": "#/components/schemas/ShareLinkScope"
///         },
///         "expires_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Expires At"
///         },
///         "max_views": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Max Views"
///         },
///         "media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Media Asset Ids"
///         }
///     },
///     "type": "object",
///     "required": [
///         "scope"
///     ],
///     "title": "ShareLinkCreateRequest"
/// }
library share_link_create_request;

import 'exports.dart';
part 'share_link_create_request.freezed.dart';
part 'share_link_create_request.g.dart'; // ShareLinkCreateRequest

@freezed
abstract class ShareLinkCreateRequest with _$ShareLinkCreateRequest {
  const ShareLinkCreateRequest._();

  @jsonSerializable
  const factory ShareLinkCreateRequest({
    /// scope
    @JsonKey(name: ShareLinkCreateRequest.scopeKey_)
    required ShareLinkScope scope,

    /// expiresAt
    @JsonKey(name: ShareLinkCreateRequest.expiresAtKey_) DateTime? expiresAt,

    /// maxViews
    @JsonKey(name: ShareLinkCreateRequest.maxViewsKey_) int? maxViews,

    /// mediaAssetIds
    @JsonKey(name: ShareLinkCreateRequest.mediaAssetIdsKey_)
    List<String>? mediaAssetIds,
  }) = _ShareLinkCreateRequest;

  factory ShareLinkCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ShareLinkCreateRequestFromJson(json);

  static const String scopeKey_ = r'scope';

  static const String expiresAtKey_ = r'expires_at';

  static const String maxViewsKey_ = r'max_views';

  static const String mediaAssetIdsKey_ = r'media_asset_ids';
}
