/// GearFrameSubmitRequest
/// {
///     "properties": {
///         "evidence_media_asset_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Evidence Media Asset Id"
///         }
///     },
///     "type": "object",
///     "required": [
///         "evidence_media_asset_id"
///     ],
///     "title": "GearFrameSubmitRequest"
/// }
library gear_frame_submit_request;

import 'exports.dart';
part 'gear_frame_submit_request.freezed.dart';
part 'gear_frame_submit_request.g.dart'; // GearFrameSubmitRequest

@freezed
abstract class GearFrameSubmitRequest with _$GearFrameSubmitRequest {
  const GearFrameSubmitRequest._();

  @jsonSerializable
  const factory GearFrameSubmitRequest({
    /// evidenceMediaAssetId
    @JsonKey(name: GearFrameSubmitRequest.evidenceMediaAssetIdKey_)
    required String evidenceMediaAssetId,
  }) = _GearFrameSubmitRequest;

  factory GearFrameSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$GearFrameSubmitRequestFromJson(json);

  static const String evidenceMediaAssetIdKey_ = r'evidence_media_asset_id';
}
