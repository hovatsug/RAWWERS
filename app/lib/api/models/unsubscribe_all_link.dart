/// UnsubscribeAllLink
/// {
///     "properties": {
///         "k": {
///             "type": "string",
///             "title": "K"
///         },
///         "s": {
///             "type": "string",
///             "title": "S"
///         }
///     },
///     "type": "object",
///     "required": [
///         "k",
///         "s"
///     ],
///     "title": "UnsubscribeAllLink"
/// }
library unsubscribe_all_link;

import 'exports.dart';
part 'unsubscribe_all_link.freezed.dart';
part 'unsubscribe_all_link.g.dart'; // UnsubscribeAllLink

@freezed
abstract class UnsubscribeAllLink with _$UnsubscribeAllLink {
  const UnsubscribeAllLink._();

  @jsonSerializable
  const factory UnsubscribeAllLink({
    /// k
    @JsonKey(name: UnsubscribeAllLink.kKey_) required String k,

    /// s
    @JsonKey(name: UnsubscribeAllLink.sKey_) required String s,
  }) = _UnsubscribeAllLink;

  factory UnsubscribeAllLink.fromJson(Map<String, dynamic> json) =>
      _$UnsubscribeAllLinkFromJson(json);

  static const String kKey_ = r'k';

  static const String sKey_ = r's';
}
