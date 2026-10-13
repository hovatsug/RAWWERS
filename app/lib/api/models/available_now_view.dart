/// AvailableNowView
/// {
///     "properties": {
///         "switched_on": {
///             "type": "boolean",
///             "title": "Switched On"
///         },
///         "available_until": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Available Until"
///         },
///         "effective": {
///             "type": "boolean",
///             "title": "Effective"
///         },
///         "prep_hours": {
///             "type": "integer",
///             "title": "Prep Hours"
///         },
///         "eligible_package_ids": {
///             "type": "array",
///             "items": {
///                 "type": "string",
///                 "format": "uuid"
///             },
///             "title": "Eligible Package Ids"
///         },
///         "lasts_hours": {
///             "type": "integer",
///             "title": "Lasts Hours"
///         }
///     },
///     "type": "object",
///     "required": [
///         "switched_on",
///         "effective",
///         "prep_hours",
///         "lasts_hours"
///     ],
///     "title": "AvailableNowView"
/// }
library available_now_view;

import 'exports.dart';
part 'available_now_view.freezed.dart';
part 'available_now_view.g.dart'; // AvailableNowView

@freezed
abstract class AvailableNowView with _$AvailableNowView {
  const AvailableNowView._();

  @jsonSerializable
  const factory AvailableNowView({
    /// switchedOn
    @JsonKey(name: AvailableNowView.switchedOnKey_) required bool switchedOn,

    /// availableUntil
    @JsonKey(name: AvailableNowView.availableUntilKey_)
    DateTime? availableUntil,

    /// effective
    @JsonKey(name: AvailableNowView.effectiveKey_) required bool effective,

    /// prepHours
    @JsonKey(name: AvailableNowView.prepHoursKey_) required int prepHours,

    /// eligiblePackageIds
    @JsonKey(name: AvailableNowView.eligiblePackageIdsKey_)
    List<String>? eligiblePackageIds,

    /// lastsHours
    @JsonKey(name: AvailableNowView.lastsHoursKey_) required int lastsHours,
  }) = _AvailableNowView;

  factory AvailableNowView.fromJson(Map<String, dynamic> json) =>
      _$AvailableNowViewFromJson(json);

  static const String switchedOnKey_ = r'switched_on';

  static const String availableUntilKey_ = r'available_until';

  static const String effectiveKey_ = r'effective';

  static const String prepHoursKey_ = r'prep_hours';

  static const String eligiblePackageIdsKey_ = r'eligible_package_ids';

  static const String lastsHoursKey_ = r'lasts_hours';
}
