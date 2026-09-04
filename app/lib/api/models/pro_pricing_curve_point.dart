/// ProPricingCurvePoint
/// {
///     "properties": {
///         "photo_count": {
///             "type": "integer",
///             "title": "Photo Count"
///         },
///         "total": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Total"
///         },
///         "per_photo": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Per Photo"
///         }
///     },
///     "type": "object",
///     "required": [
///         "photo_count",
///         "total",
///         "per_photo"
///     ],
///     "title": "ProPricingCurvePoint"
/// }
library pro_pricing_curve_point;

import 'exports.dart';
part 'pro_pricing_curve_point.freezed.dart';
part 'pro_pricing_curve_point.g.dart'; // ProPricingCurvePoint

@freezed
abstract class ProPricingCurvePoint with _$ProPricingCurvePoint {
  const ProPricingCurvePoint._();

  @jsonSerializable
  const factory ProPricingCurvePoint({
    /// photoCount
    @JsonKey(name: ProPricingCurvePoint.photoCountKey_) required int photoCount,

    /// total
    @JsonKey(name: ProPricingCurvePoint.totalKey_) required String total,

    /// perPhoto
    @JsonKey(name: ProPricingCurvePoint.perPhotoKey_) required String perPhoto,
  }) = _ProPricingCurvePoint;

  factory ProPricingCurvePoint.fromJson(Map<String, dynamic> json) =>
      _$ProPricingCurvePointFromJson(json);

  static const String photoCountKey_ = r'photo_count';

  static const String totalKey_ = r'total';

  static const String perPhotoKey_ = r'per_photo';
}
