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
///         "prep_minutes": {
///             "type": "integer",
///             "title": "Prep Minutes"
///         },
///         "prep_options_minutes": {
///             "type": "array",
///             "items": {
///                 "type": "integer"
///             },
///             "title": "Prep Options Minutes"
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
///         "prep_minutes",
///         "prep_options_minutes",
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

    /// prepMinutes
    @JsonKey(name: AvailableNowView.prepMinutesKey_) required int prepMinutes,

    /// prepOptionsMinutes
    @JsonKey(name: AvailableNowView.prepOptionsMinutesKey_)
    required List<int> prepOptionsMinutes,

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

  static const String prepMinutesKey_ = r'prep_minutes';

  static const String prepOptionsMinutesKey_ = r'prep_options_minutes';

  static const String eligiblePackageIdsKey_ = r'eligible_package_ids';

  static const String lastsHoursKey_ = r'lasts_hours';
}
