/// ProNichePricingPreviewResponse
/// {
///     "properties": {
///         "niche_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Niche Id"
///         },
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "niche_name": {
///             "type": "string",
///             "title": "Niche Name"
///         },
///         "tier": {
///             "type": "string",
///             "title": "Tier"
///         },
///         "entry_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Entry Price"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "entry_price_min": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Entry Price Min"
///         },
///         "entry_price_max": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Entry Price Max"
///         },
///         "within_cap": {
///             "type": "boolean",
///             "title": "Within Cap"
///         },
///         "curve": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProPricingCurvePoint"
///             },
///             "title": "Curve"
///         }
///     },
///     "type": "object",
///     "required": [
///         "niche_id",
///         "niche_slug",
///         "niche_name",
///         "tier",
///         "entry_price",
///         "currency",
///         "entry_price_min",
///         "within_cap"
///     ],
///     "title": "ProNichePricingPreviewResponse"
/// }
library pro_niche_pricing_preview_response;

import 'exports.dart';
part 'pro_niche_pricing_preview_response.freezed.dart';
part 'pro_niche_pricing_preview_response.g.dart'; // ProNichePricingPreviewResponse

@freezed
abstract class ProNichePricingPreviewResponse
    with _$ProNichePricingPreviewResponse {
  const ProNichePricingPreviewResponse._();

  @jsonSerializable
  const factory ProNichePricingPreviewResponse({
    /// nicheId
    @JsonKey(name: ProNichePricingPreviewResponse.nicheIdKey_)
    required String nicheId,

    /// nicheSlug
    @JsonKey(name: ProNichePricingPreviewResponse.nicheSlugKey_)
    required String nicheSlug,

    /// nicheName
    @JsonKey(name: ProNichePricingPreviewResponse.nicheNameKey_)
    required String nicheName,

    /// tier
    @JsonKey(name: ProNichePricingPreviewResponse.tierKey_)
    required String tier,

    /// entryPrice
    @JsonKey(name: ProNichePricingPreviewResponse.entryPriceKey_)
    required String entryPrice,

    /// currency
    @JsonKey(name: ProNichePricingPreviewResponse.currencyKey_)
    required String currency,

    /// entryPriceMin
    @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMinKey_)
    required String entryPriceMin,

    /// entryPriceMax
    @JsonKey(name: ProNichePricingPreviewResponse.entryPriceMaxKey_)
    String? entryPriceMax,

    /// withinCap
    @JsonKey(name: ProNichePricingPreviewResponse.withinCapKey_)
    required bool withinCap,

    /// curve
    @JsonKey(name: ProNichePricingPreviewResponse.curveKey_)
    List<ProPricingCurvePoint>? curve,
  }) = _ProNichePricingPreviewResponse;

  factory ProNichePricingPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ProNichePricingPreviewResponseFromJson(json);

  static const String nicheIdKey_ = r'niche_id';

  static const String nicheSlugKey_ = r'niche_slug';

  static const String nicheNameKey_ = r'niche_name';

  static const String tierKey_ = r'tier';

  static const String entryPriceKey_ = r'entry_price';

  static const String currencyKey_ = r'currency';

  static const String entryPriceMinKey_ = r'entry_price_min';

  static const String entryPriceMaxKey_ = r'entry_price_max';

  static const String withinCapKey_ = r'within_cap';

  static const String curveKey_ = r'curve';
}
