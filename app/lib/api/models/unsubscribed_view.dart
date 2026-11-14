/// UnsubscribedView
/// {
///     "properties": {
///         "topic": {
///             "type": "string",
///             "title": "Topic"
///         },
///         "unsubscribed": {
///             "type": "boolean",
///             "title": "Unsubscribed"
///         }
///     },
///     "type": "object",
///     "required": [
///         "topic",
///         "unsubscribed"
///     ],
///     "title": "UnsubscribedView"
/// }
library unsubscribed_view;

import 'exports.dart';
part 'unsubscribed_view.freezed.dart';
part 'unsubscribed_view.g.dart'; // UnsubscribedView

@freezed
abstract class UnsubscribedView with _$UnsubscribedView {
  const UnsubscribedView._();

  @jsonSerializable
  const factory UnsubscribedView({
    /// topic
    @JsonKey(name: UnsubscribedView.topicKey_) required String topic,

    /// unsubscribed
    @JsonKey(name: UnsubscribedView.unsubscribedKey_)
    required bool unsubscribed,
  }) = _UnsubscribedView;

  factory UnsubscribedView.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribedViewFromJson(json);

  static const String topicKey_ = r'topic';

  static const String unsubscribedKey_ = r'unsubscribed';
}
