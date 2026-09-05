/// PortfolioNicheTagsRequest
/// {
///     "properties": {
///         "niche_slugs": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Niche Slugs"
///         }
///     },
///     "type": "object",
///     "title": "PortfolioNicheTagsRequest"
/// }
library portfolio_niche_tags_request;

import 'exports.dart';
part 'portfolio_niche_tags_request.freezed.dart';
part 'portfolio_niche_tags_request.g.dart'; // PortfolioNicheTagsRequest

@freezed
abstract class PortfolioNicheTagsRequest with _$PortfolioNicheTagsRequest {
  const PortfolioNicheTagsRequest._();

  @jsonSerializable
  const factory PortfolioNicheTagsRequest({
    /// nicheSlugs
    @JsonKey(name: PortfolioNicheTagsRequest.nicheSlugsKey_)
    List<String>? nicheSlugs,
  }) = _PortfolioNicheTagsRequest;

  factory PortfolioNicheTagsRequest.fromJson(Map<String, dynamic> json) =>
      _$PortfolioNicheTagsRequestFromJson(json);

  static const String nicheSlugsKey_ = r'niche_slugs';
}
