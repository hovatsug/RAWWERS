/// ProCoverResponse
/// {
///     "properties": {
///         "cover_media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Cover Media Asset Id"
///         },
///         "changed": {
///             "type": "boolean",
///             "title": "Changed"
///         }
///     },
///     "type": "object",
///     "required": [
///         "cover_media_asset_id",
///         "changed"
///     ],
///     "title": "ProCoverResponse"
/// }
library pro_cover_response;

import 'exports.dart';
part 'pro_cover_response.freezed.dart';
part 'pro_cover_response.g.dart'; // ProCoverResponse

@freezed
abstract class ProCoverResponse with _$ProCoverResponse {
  const ProCoverResponse._();

  @jsonSerializable
  const factory ProCoverResponse({
    /// coverMediaAssetId
    @JsonKey(name: ProCoverResponse.coverMediaAssetIdKey_)
    required String coverMediaAssetId,

    /// changed
    @JsonKey(name: ProCoverResponse.changedKey_) required bool changed,
  }) = _ProCoverResponse;

  factory ProCoverResponse.fromJson(Map<String, dynamic> json) =>
      _$ProCoverResponseFromJson(json);

  static const String coverMediaAssetIdKey_ = r'cover_media_asset_id';

  static const String changedKey_ = r'changed';
}
