/// NotificationAction
/// {
///     "properties": {
///         "label": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Label"
///         },
///         "url": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Url"
///         }
///     },
///     "type": "object",
///     "title": "NotificationAction"
/// }
library notification_action;

import 'exports.dart';
part 'notification_action.freezed.dart';
part 'notification_action.g.dart'; // NotificationAction

@freezed
abstract class NotificationAction with _$NotificationAction {
  const NotificationAction._();

  @jsonSerializable
  const factory NotificationAction({
    /// label
    @JsonKey(name: NotificationAction.labelKey_) String? label,

    /// url
    @JsonKey(name: NotificationAction.urlKey_) String? url,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionFromJson(json);

  static const String labelKey_ = r'label';

  static const String urlKey_ = r'url';
}
