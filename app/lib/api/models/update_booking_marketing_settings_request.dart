/// UpdateBookingMarketingSettingsRequest
/// {
///     "properties": {
///         "allow_marketing": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Allow Marketing"
///         },
///         "includes_children": {
///             "anyOf": [
///                 {
///                     "type": "boolean"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Includes Children"
///         }
///     },
///     "type": "object",
///     "title": "UpdateBookingMarketingSettingsRequest"
/// }
library update_booking_marketing_settings_request;

import 'exports.dart';
part 'update_booking_marketing_settings_request.freezed.dart';
part 'update_booking_marketing_settings_request.g.dart'; // UpdateBookingMarketingSettingsRequest

@freezed
abstract class UpdateBookingMarketingSettingsRequest
    with _$UpdateBookingMarketingSettingsRequest {
  const UpdateBookingMarketingSettingsRequest._();

  @jsonSerializable
  const factory UpdateBookingMarketingSettingsRequest({
    /// allowMarketing
    @JsonKey(name: UpdateBookingMarketingSettingsRequest.allowMarketingKey_)
    bool? allowMarketing,

    /// includesChildren
    @JsonKey(name: UpdateBookingMarketingSettingsRequest.includesChildrenKey_)
    bool? includesChildren,
  }) = _UpdateBookingMarketingSettingsRequest;

  factory UpdateBookingMarketingSettingsRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateBookingMarketingSettingsRequestFromJson(json);

  static const String allowMarketingKey_ = r'allow_marketing';

  static const String includesChildrenKey_ = r'includes_children';
}
