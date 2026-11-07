/// StartAddonRequest
/// {
///     "properties": {
///         "media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Media Asset Ids"
///         },
///         "client_request_id": {
///             "type": "string",
///             "title": "Client Request Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "media_asset_ids",
///         "client_request_id"
///     ],
///     "title": "StartAddonRequest"
/// }
library start_addon_request;

import 'exports.dart';
part 'start_addon_request.freezed.dart';
part 'start_addon_request.g.dart'; // StartAddonRequest

@freezed
abstract class StartAddonRequest with _$StartAddonRequest {
  const StartAddonRequest._();

  @jsonSerializable
  const factory StartAddonRequest({
    /// mediaAssetIds
    @JsonKey(name: StartAddonRequest.mediaAssetIdsKey_)
    required List<String> mediaAssetIds,

    /// clientRequestId
    @JsonKey(name: StartAddonRequest.clientRequestIdKey_)
    required String clientRequestId,
  }) = _StartAddonRequest;

  factory StartAddonRequest.fromJson(Map<String, dynamic> json) =>
      _$StartAddonRequestFromJson(json);

  static const String mediaAssetIdsKey_ = r'media_asset_ids';

  static const String clientRequestIdKey_ = r'client_request_id';
}
