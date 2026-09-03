/// ShareLinkViewResponse
/// {
///     "properties": {
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
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
///         "view_count": {
///             "type": "integer",
///             "title": "View Count"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/SharedMediaItemView"
///             },
///             "title": "Items"
///         },
///         "powered_by_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Powered By Text"
///         },
///         "create_gallery_cta_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Create Gallery Cta Text"
///         },
///         "create_gallery_cta_url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Create Gallery Cta Url"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig_id",
///         "scope",
///         "view_count"
///     ],
///     "title": "ShareLinkViewResponse"
/// }
library share_link_view_response;

import 'exports.dart';
part 'share_link_view_response.freezed.dart';
part 'share_link_view_response.g.dart'; // ShareLinkViewResponse

@freezed
abstract class ShareLinkViewResponse with _$ShareLinkViewResponse {
  const ShareLinkViewResponse._();

  @jsonSerializable
  const factory ShareLinkViewResponse({
    /// gigId
    @JsonKey(name: ShareLinkViewResponse.gigIdKey_) required String gigId,

    /// scope
    @JsonKey(name: ShareLinkViewResponse.scopeKey_)
    required ShareLinkScope scope,

    /// expiresAt
    @JsonKey(name: ShareLinkViewResponse.expiresAtKey_) DateTime? expiresAt,

    /// maxViews
    @JsonKey(name: ShareLinkViewResponse.maxViewsKey_) int? maxViews,

    /// viewCount
    @JsonKey(name: ShareLinkViewResponse.viewCountKey_) required int viewCount,

    /// items
    @JsonKey(name: ShareLinkViewResponse.itemsKey_)
    List<SharedMediaItemView>? items,

    /// poweredByText
    @JsonKey(name: ShareLinkViewResponse.poweredByTextKey_)
    String? poweredByText,

    /// createGalleryCtaText
    @JsonKey(name: ShareLinkViewResponse.createGalleryCtaTextKey_)
    String? createGalleryCtaText,

    /// createGalleryCtaUrl
    @JsonKey(name: ShareLinkViewResponse.createGalleryCtaUrlKey_)
    String? createGalleryCtaUrl,
  }) = _ShareLinkViewResponse;

  factory ShareLinkViewResponse.fromJson(Map<String, dynamic> json) =>
      _$ShareLinkViewResponseFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String scopeKey_ = r'scope';

  static const String expiresAtKey_ = r'expires_at';

  static const String maxViewsKey_ = r'max_views';

  static const String viewCountKey_ = r'view_count';

  static const String itemsKey_ = r'items';

  static const String poweredByTextKey_ = r'powered_by_text';

  static const String createGalleryCtaTextKey_ = r'create_gallery_cta_text';

  static const String createGalleryCtaUrlKey_ = r'create_gallery_cta_url';
}
