/// ProPortfolioRemoveResponse
/// {
///     "properties": {
///         "media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Media Asset Id"
///         },
///         "removed": {
///             "type": "boolean",
///             "title": "Removed"
///         },
///         "cover_cleared": {
///             "type": "boolean",
///             "default": false,
///             "title": "Cover Cleared"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_id",
///         "removed"
///     ],
///     "title": "ProPortfolioRemoveResponse"
/// }
library pro_portfolio_remove_response;

import 'exports.dart';
part 'pro_portfolio_remove_response.freezed.dart';
part 'pro_portfolio_remove_response.g.dart'; // ProPortfolioRemoveResponse

@freezed
abstract class ProPortfolioRemoveResponse with _$ProPortfolioRemoveResponse {
  const ProPortfolioRemoveResponse._();

  @jsonSerializable
  const factory ProPortfolioRemoveResponse({
    /// mediaAssetId
    @JsonKey(name: ProPortfolioRemoveResponse.mediaAssetIdKey_)
    required String mediaAssetId,

    /// removed
    @JsonKey(name: ProPortfolioRemoveResponse.removedKey_)
    required bool removed,

    /// coverCleared
    @Default(false)
    @JsonKey(name: ProPortfolioRemoveResponse.coverClearedKey_)
    bool coverCleared,
  }) = _ProPortfolioRemoveResponse;

  factory ProPortfolioRemoveResponse.fromJson(Map<String, dynamic> json) =>
      _$ProPortfolioRemoveResponseFromJson(json);

  static const String mediaAssetIdKey_ = r'media_asset_id';

  static const String removedKey_ = r'removed';

  static const String coverClearedKey_ = r'cover_cleared';
}
