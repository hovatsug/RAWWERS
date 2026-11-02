/// BookingMarketingSettingsView
/// {
///     "properties": {
///         "allow_marketing": {
///             "type": "boolean",
///             "title": "Allow Marketing"
///         },
///         "includes_children": {
///             "type": "boolean",
///             "title": "Includes Children"
///         },
///         "locked": {
///             "type": "boolean",
///             "title": "Locked"
///         },
///         "opted_in": {
///             "type": "boolean",
///             "title": "Opted In"
///         }
///     },
///     "type": "object",
///     "required": [
///         "allow_marketing",
///         "includes_children",
///         "locked",
///         "opted_in"
///     ],
///     "title": "BookingMarketingSettingsView"
/// }
library booking_marketing_settings_view;

import 'exports.dart';
part 'booking_marketing_settings_view.freezed.dart';
part 'booking_marketing_settings_view.g.dart'; // BookingMarketingSettingsView

@freezed
abstract class BookingMarketingSettingsView
    with _$BookingMarketingSettingsView {
  const BookingMarketingSettingsView._();

  @jsonSerializable
  const factory BookingMarketingSettingsView({
    /// allowMarketing
    @JsonKey(name: BookingMarketingSettingsView.allowMarketingKey_)
    required bool allowMarketing,

    /// includesChildren
    @JsonKey(name: BookingMarketingSettingsView.includesChildrenKey_)
    required bool includesChildren,

    /// locked
    @JsonKey(name: BookingMarketingSettingsView.lockedKey_)
    required bool locked,

    /// optedIn
    @JsonKey(name: BookingMarketingSettingsView.optedInKey_)
    required bool optedIn,
  }) = _BookingMarketingSettingsView;

  factory BookingMarketingSettingsView.fromJson(Map<String, dynamic> json) =>
      _$BookingMarketingSettingsViewFromJson(json);

  static const String allowMarketingKey_ = r'allow_marketing';

  static const String includesChildrenKey_ = r'includes_children';

  static const String lockedKey_ = r'locked';

  static const String optedInKey_ = r'opted_in';
}
