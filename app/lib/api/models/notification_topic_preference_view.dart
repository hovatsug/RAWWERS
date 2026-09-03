/// NotificationTopicPreferenceView
/// {
///     "properties": {
///         "topic": {
///             "type": "string",
///             "title": "Topic"
///         },
///         "email_enabled": {
///             "type": "boolean",
///             "title": "Email Enabled"
///         },
///         "inapp_enabled": {
///             "type": "boolean",
///             "title": "Inapp Enabled"
///         }
///     },
///     "type": "object",
///     "required": [
///         "topic",
///         "email_enabled",
///         "inapp_enabled"
///     ],
///     "title": "NotificationTopicPreferenceView"
/// }
library notification_topic_preference_view;

import 'exports.dart';
part 'notification_topic_preference_view.freezed.dart';
part 'notification_topic_preference_view.g.dart'; // NotificationTopicPreferenceView

@freezed
abstract class NotificationTopicPreferenceView
    with _$NotificationTopicPreferenceView {
  const NotificationTopicPreferenceView._();

  @jsonSerializable
  const factory NotificationTopicPreferenceView({
    /// topic
    @JsonKey(name: NotificationTopicPreferenceView.topicKey_)
    required String topic,

    /// emailEnabled
    @JsonKey(name: NotificationTopicPreferenceView.emailEnabledKey_)
    required bool emailEnabled,

    /// inappEnabled
    @JsonKey(name: NotificationTopicPreferenceView.inappEnabledKey_)
    required bool inappEnabled,
  }) = _NotificationTopicPreferenceView;

  factory NotificationTopicPreferenceView.fromJson(Map<String, dynamic> json) =>
      _$NotificationTopicPreferenceViewFromJson(json);

  static const String topicKey_ = r'topic';

  static const String emailEnabledKey_ = r'email_enabled';

  static const String inappEnabledKey_ = r'inapp_enabled';
}
