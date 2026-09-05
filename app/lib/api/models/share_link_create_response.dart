/// ShareLinkCreateResponse
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "token": {
///             "type": "string",
///             "title": "Token"
///         },
///         "share_url": {
///             "type": "string",
///             "title": "Share Url"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "token",
///         "share_url"
///     ],
///     "title": "ShareLinkCreateResponse"
/// }
library share_link_create_response;

import 'exports.dart';
part 'share_link_create_response.freezed.dart';
part 'share_link_create_response.g.dart'; // ShareLinkCreateResponse

@freezed
abstract class ShareLinkCreateResponse with _$ShareLinkCreateResponse {
  const ShareLinkCreateResponse._();

  @jsonSerializable
  const factory ShareLinkCreateResponse({
    /// id
    @JsonKey(name: ShareLinkCreateResponse.idKey_) required String id,

    /// token
    @JsonKey(name: ShareLinkCreateResponse.tokenKey_) required String token,

    /// shareUrl
    @JsonKey(name: ShareLinkCreateResponse.shareUrlKey_)
    required String shareUrl,

    /// expiresAt
    @JsonKey(name: ShareLinkCreateResponse.expiresAtKey_) DateTime? expiresAt,

    /// maxViews
    @JsonKey(name: ShareLinkCreateResponse.maxViewsKey_) int? maxViews,
  }) = _ShareLinkCreateResponse;

  factory ShareLinkCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$ShareLinkCreateResponseFromJson(json);

  static const String idKey_ = r'id';

  static const String tokenKey_ = r'token';

  static const String shareUrlKey_ = r'share_url';

  static const String expiresAtKey_ = r'expires_at';

  static const String maxViewsKey_ = r'max_views';
}
