/// NichePricingPreviewResponse
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "niche_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Niche Id"
///         },
///         "packages": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/PackagePricingPreview"
///             },
///             "title": "Packages"
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "niche_id",
///         "packages"
///     ],
///     "title": "NichePricingPreviewResponse"
/// }
library niche_pricing_preview_response;

import 'exports.dart';
part 'niche_pricing_preview_response.freezed.dart';
part 'niche_pricing_preview_response.g.dart'; // NichePricingPreviewResponse

@freezed
abstract class NichePricingPreviewResponse with _$NichePricingPreviewResponse {
  const NichePricingPreviewResponse._();

  @jsonSerializable
  const factory NichePricingPreviewResponse({
    /// proUserId
    @JsonKey(name: NichePricingPreviewResponse.proUserIdKey_)
    required String proUserId,

    /// nicheId
    @JsonKey(name: NichePricingPreviewResponse.nicheIdKey_)
    required String nicheId,

    /// packages
    @JsonKey(name: NichePricingPreviewResponse.packagesKey_)
    required List<PackagePricingPreview> packages,
  }) = _NichePricingPreviewResponse;

  factory NichePricingPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$NichePricingPreviewResponseFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheIdKey_ = r'niche_id';

  static const String packagesKey_ = r'packages';
}
