/// PresenceVisibility
/// {
///     "properties": {
///         "visible": {
///             "type": "boolean",
///             "title": "Visible"
///         }
///     },
///     "type": "object",
///     "required": [
///         "visible"
///     ],
///     "title": "PresenceVisibility"
/// }
library presence_visibility;

import 'exports.dart';
part 'presence_visibility.freezed.dart';
part 'presence_visibility.g.dart'; // PresenceVisibility

@freezed
abstract class PresenceVisibility with _$PresenceVisibility {
  const PresenceVisibility._();

  @jsonSerializable
  const factory PresenceVisibility({
    /// visible
    @JsonKey(name: PresenceVisibility.visibleKey_) required bool visible,
  }) = _PresenceVisibility;

  factory PresenceVisibility.fromJson(Map<String, dynamic> json) =>
      _$PresenceVisibilityFromJson(json);

  static const String visibleKey_ = r'visible';
}
