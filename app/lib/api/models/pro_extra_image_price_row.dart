/// ProExtraImagePriceRow
/// {
///     "properties": {
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "niche_name": {
///             "type": "string",
///             "title": "Niche Name"
///         },
///         "configured_unit_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Configured Unit Price"
///         },
///         "applied_unit_price": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Applied Unit Price"
///         },
///         "policy_min": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Policy Min"
///         },
///         "policy_max": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Policy Max"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         }
///     },
///     "type": "object",
///     "required": [
///         "niche_slug",
///         "niche_name",
///         "configured_unit_price",
///         "applied_unit_price",
///         "policy_min",
///         "currency"
///     ],
///     "title": "ProExtraImagePriceRow"
/// }
library pro_extra_image_price_row;

import 'exports.dart';
part 'pro_extra_image_price_row.freezed.dart';
part 'pro_extra_image_price_row.g.dart'; // ProExtraImagePriceRow

@freezed
abstract class ProExtraImagePriceRow with _$ProExtraImagePriceRow {
  const ProExtraImagePriceRow._();

  @jsonSerializable
  const factory ProExtraImagePriceRow({
    /// nicheSlug
    @JsonKey(name: ProExtraImagePriceRow.nicheSlugKey_)
    required String nicheSlug,

    /// nicheName
    @JsonKey(name: ProExtraImagePriceRow.nicheNameKey_)
    required String nicheName,

    /// configuredUnitPrice
    @JsonKey(name: ProExtraImagePriceRow.configuredUnitPriceKey_)
    required String configuredUnitPrice,

    /// appliedUnitPrice
    @JsonKey(name: ProExtraImagePriceRow.appliedUnitPriceKey_)
    required String appliedUnitPrice,

    /// policyMin
    @JsonKey(name: ProExtraImagePriceRow.policyMinKey_)
    required String policyMin,

    /// policyMax
    @JsonKey(name: ProExtraImagePriceRow.policyMaxKey_) String? policyMax,

    /// currency
    @JsonKey(name: ProExtraImagePriceRow.currencyKey_) required String currency,
  }) = _ProExtraImagePriceRow;

  factory ProExtraImagePriceRow.fromJson(Map<String, dynamic> json) =>
      _$ProExtraImagePriceRowFromJson(json);

  static const String nicheSlugKey_ = r'niche_slug';

  static const String nicheNameKey_ = r'niche_name';

  static const String configuredUnitPriceKey_ = r'configured_unit_price';

  static const String appliedUnitPriceKey_ = r'applied_unit_price';

  static const String policyMinKey_ = r'policy_min';

  static const String policyMaxKey_ = r'policy_max';

  static const String currencyKey_ = r'currency';
}
