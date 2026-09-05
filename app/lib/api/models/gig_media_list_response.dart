/// GigMediaListResponse
/// {
///     "properties": {
///         "gig_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Gig Id"
///         },
///         "assets": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/GigMediaAssetView"
///             },
///             "title": "Assets"
///         }
///     },
///     "type": "object",
///     "required": [
///         "gig_id"
///     ],
///     "title": "GigMediaListResponse"
/// }
library gig_media_list_response;

import 'exports.dart';
part 'gig_media_list_response.freezed.dart';
part 'gig_media_list_response.g.dart'; // GigMediaListResponse

@freezed
abstract class GigMediaListResponse with _$GigMediaListResponse {
  const GigMediaListResponse._();

  @jsonSerializable
  const factory GigMediaListResponse({
    /// gigId
    @JsonKey(name: GigMediaListResponse.gigIdKey_) required String gigId,

    /// assets
    @JsonKey(name: GigMediaListResponse.assetsKey_)
    List<GigMediaAssetView>? assets,
  }) = _GigMediaListResponse;

  factory GigMediaListResponse.fromJson(Map<String, dynamic> json) =>
      _$GigMediaListResponseFromJson(json);

  static const String gigIdKey_ = r'gig_id';

  static const String assetsKey_ = r'assets';
}
