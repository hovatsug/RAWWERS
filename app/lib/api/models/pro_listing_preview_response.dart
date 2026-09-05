/// ProListingPreviewResponse
/// {
///     "properties": {
///         "card": {
///             "$ref": "#/components/schemas/ClientDiscoverCard"
///         },
///         "is_live": {
///             "type": "boolean",
///             "title": "Is Live"
///         },
///         "blocking_reasons": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Blocking Reasons"
///         },
///         "available_days_next_14": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Available Days Next 14"
///         }
///     },
///     "type": "object",
///     "required": [
///         "card",
///         "is_live"
///     ],
///     "title": "ProListingPreviewResponse",
///     "description": "What a client sees, returned to the pro who owns it.\n\n`card` is built by the same function that builds the Discover feed, so\nthe preview cannot drift from the real thing - if editing a package\nchanges the price range here, it changes it there."
/// }
library pro_listing_preview_response;

import 'exports.dart';
part 'pro_listing_preview_response.freezed.dart';
part 'pro_listing_preview_response.g.dart'; // ProListingPreviewResponse

@freezed
abstract class ProListingPreviewResponse with _$ProListingPreviewResponse {
  const ProListingPreviewResponse._();

  @jsonSerializable
  const factory ProListingPreviewResponse({
    /// card
    @JsonKey(name: ProListingPreviewResponse.cardKey_)
    required ClientDiscoverCard card,

    /// isLive
    @JsonKey(name: ProListingPreviewResponse.isLiveKey_) required bool isLive,

    /// blockingReasons
    @JsonKey(name: ProListingPreviewResponse.blockingReasonsKey_)
    List<String>? blockingReasons,

    /// availableDaysNext14
    @JsonKey(name: ProListingPreviewResponse.availableDaysNext14Key_)
    int? availableDaysNext14,
  }) = _ProListingPreviewResponse;

  factory ProListingPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ProListingPreviewResponseFromJson(json);

  static const String cardKey_ = r'card';

  static const String isLiveKey_ = r'is_live';

  static const String blockingReasonsKey_ = r'blocking_reasons';

  static const String availableDaysNext14Key_ = r'available_days_next_14';
}
