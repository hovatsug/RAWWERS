/// ClientHomeRow
/// {
///     "properties": {
///         "key": {
///             "type": "string",
///             "title": "Key"
///         },
///         "title": {
///             "type": "string",
///             "title": "Title"
///         },
///         "subtitle": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Subtitle"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientDiscoverCard"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "key",
///         "title"
///     ],
///     "title": "ClientHomeRow",
///     "description": "One horizontal row on the client home screen.\n\n`key` is stable and machine-readable so the app can special-case\npresentation; `title` is what the client reads. Both are decided by the\nserver rather than the app, because what belongs in a row is a fairness\nrule - \"new photographers\" must never quietly blend into \"most\nexperienced\" - and a rule implemented in more than one place drifts. This\nproject has already paid for that once, in pricing."
/// }
library client_home_row;

import 'exports.dart';
part 'client_home_row.freezed.dart';
part 'client_home_row.g.dart'; // ClientHomeRow

@freezed
abstract class ClientHomeRow with _$ClientHomeRow {
  const ClientHomeRow._();

  @jsonSerializable
  const factory ClientHomeRow({
    /// key
    @JsonKey(name: ClientHomeRow.keyKey_) required String key,

    /// title
    @JsonKey(name: ClientHomeRow.titleKey_) required String title,

    /// subtitle
    @JsonKey(name: ClientHomeRow.subtitleKey_) String? subtitle,

    /// items
    @JsonKey(name: ClientHomeRow.itemsKey_) List<ClientDiscoverCard>? items,
  }) = _ClientHomeRow;

  factory ClientHomeRow.fromJson(Map<String, dynamic> json) =>
      _$ClientHomeRowFromJson(json);

  static const String keyKey_ = r'key';

  static const String titleKey_ = r'title';

  static const String subtitleKey_ = r'subtitle';

  static const String itemsKey_ = r'items';
}
