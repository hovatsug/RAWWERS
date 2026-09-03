/// NotificationTopicPreferenceUpsert
/// {
///     "properties": {
///         "topic": {
///             "type": "string",
///             "title": "Topic"
///         },
///         "email_enabled": {
///             "type": "boolean",
///             "default": true,
///             "title": "Email Enabled"
///         },
///         "inapp_enabled": {
///             "type": "boolean",
///             "default": true,
///             "title": "Inapp Enabled"
///         }
///     },
///     "type": "object",
///     "required": [
///         "topic"
///     ],
///     "title": "NotificationTopicPreferenceUpsert"
/// }
library notification_topic_preference_upsert;

import 'exports.dart';
part 'notification_topic_preference_upsert.freezed.dart';
part 'notification_topic_preference_upsert.g.dart'; // NotificationTopicPreferenceUpsert

@freezed
abstract class NotificationTopicPreferenceUpsert
    with _$NotificationTopicPreferenceUpsert {
  const NotificationTopicPreferenceUpsert._();

  @jsonSerializable
  const factory NotificationTopicPreferenceUpsert({
    /// topic
    @JsonKey(name: NotificationTopicPreferenceUpsert.topicKey_)
    required String topic,

    /// emailEnabled
    @Default(true)
    @JsonKey(name: NotificationTopicPreferenceUpsert.emailEnabledKey_)
    bool emailEnabled,

    /// inappEnabled
    @Default(true)
    @JsonKey(name: NotificationTopicPreferenceUpsert.inappEnabledKey_)
    bool inappEnabled,
  }) = _NotificationTopicPreferenceUpsert;

  factory NotificationTopicPreferenceUpsert.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationTopicPreferenceUpsertFromJson(json);

  static const String topicKey_ = r'topic';

  static const String emailEnabledKey_ = r'email_enabled';

  static const String inappEnabledKey_ = r'inapp_enabled';
}
