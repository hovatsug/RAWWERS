/// UnsubscribeLinkView
/// {
///     "properties": {
///         "topic": {
///             "type": "string",
///             "title": "Topic"
///         },
///         "topic_label": {
///             "type": "string",
///             "title": "Topic Label"
///         },
///         "all": {
///             "$ref": "#/components/schemas/UnsubscribeAllLink"
///         }
///     },
///     "type": "object",
///     "required": [
///         "topic",
///         "topic_label",
///         "all"
///     ],
///     "title": "UnsubscribeLinkView"
/// }
library unsubscribe_link_view;

import 'exports.dart';
part 'unsubscribe_link_view.freezed.dart';
part 'unsubscribe_link_view.g.dart'; // UnsubscribeLinkView

@freezed
abstract class UnsubscribeLinkView with _$UnsubscribeLinkView {
  const UnsubscribeLinkView._();

  @jsonSerializable
  const factory UnsubscribeLinkView({
    /// topic
    @JsonKey(name: UnsubscribeLinkView.topicKey_) required String topic,

    /// topicLabel
    @JsonKey(name: UnsubscribeLinkView.topicLabelKey_)
    required String topicLabel,

    /// all
    @JsonKey(name: UnsubscribeLinkView.allKey_) required UnsubscribeAllLink all,
  }) = _UnsubscribeLinkView;

  factory UnsubscribeLinkView.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeLinkViewFromJson(json);

  static const String topicKey_ = r'topic';

  static const String topicLabelKey_ = r'topic_label';

  static const String allKey_ = r'all';
}
