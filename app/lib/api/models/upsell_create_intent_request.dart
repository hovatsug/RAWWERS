/// UpsellCreateIntentRequest
/// {
///     "properties": {
///         "points_to_spend": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Points To Spend"
///         },
///         "share_link_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Share Link Id"
///         }
///     },
///     "type": "object",
///     "title": "UpsellCreateIntentRequest"
/// }
library upsell_create_intent_request;

import 'exports.dart';
part 'upsell_create_intent_request.freezed.dart';
part 'upsell_create_intent_request.g.dart'; // UpsellCreateIntentRequest

@freezed
abstract class UpsellCreateIntentRequest with _$UpsellCreateIntentRequest {
  const UpsellCreateIntentRequest._();

  @jsonSerializable
  const factory UpsellCreateIntentRequest({
    /// pointsToSpend
    @JsonKey(name: UpsellCreateIntentRequest.pointsToSpendKey_)
    int? pointsToSpend,

    /// shareLinkId
    @JsonKey(name: UpsellCreateIntentRequest.shareLinkIdKey_)
    String? shareLinkId,
  }) = _UpsellCreateIntentRequest;

  factory UpsellCreateIntentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpsellCreateIntentRequestFromJson(json);

  static const String pointsToSpendKey_ = r'points_to_spend';

  static const String shareLinkIdKey_ = r'share_link_id';
}
