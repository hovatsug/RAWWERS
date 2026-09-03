/// DisputeMessageCreateRequest
/// {
///     "properties": {
///         "message": {
///             "type": "string",
///             "title": "Message"
///         },
///         "evidence_media_asset_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Evidence Media Asset Ids"
///         }
///     },
///     "type": "object",
///     "required": [
///         "message"
///     ],
///     "title": "DisputeMessageCreateRequest"
/// }
library dispute_message_create_request;

import 'exports.dart';
part 'dispute_message_create_request.freezed.dart';
part 'dispute_message_create_request.g.dart'; // DisputeMessageCreateRequest

@freezed
abstract class DisputeMessageCreateRequest with _$DisputeMessageCreateRequest {
  const DisputeMessageCreateRequest._();

  @jsonSerializable
  const factory DisputeMessageCreateRequest({
    /// message
    @JsonKey(name: DisputeMessageCreateRequest.messageKey_)
    required String message,

    /// evidenceMediaAssetIds
    @JsonKey(name: DisputeMessageCreateRequest.evidenceMediaAssetIdsKey_)
    List<String>? evidenceMediaAssetIds,
  }) = _DisputeMessageCreateRequest;

  factory DisputeMessageCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$DisputeMessageCreateRequestFromJson(json);

  static const String messageKey_ = r'message';

  static const String evidenceMediaAssetIdsKey_ = r'evidence_media_asset_ids';
}
