/// PhotographerTeaser
/// {
///     "properties": {
///         "kind": {
///             "$ref": "#/components/schemas/TeaserKind"
///         },
///         "line": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Line"
///         }
///     },
///     "type": "object",
///     "required": [
///         "kind"
///     ],
///     "title": "PhotographerTeaser",
///     "description": "What a Discover card shows of the section, only where one exists: a play\nbadge for a video, or one line of the interview."
/// }
library photographer_teaser;

import 'exports.dart';
part 'photographer_teaser.freezed.dart';
part 'photographer_teaser.g.dart'; // PhotographerTeaser

@freezed
abstract class PhotographerTeaser with _$PhotographerTeaser {
  const PhotographerTeaser._();

  @jsonSerializable
  const factory PhotographerTeaser({
    /// kind
    @JsonKey(name: PhotographerTeaser.kindKey_) required TeaserKind kind,

    /// line
    @JsonKey(name: PhotographerTeaser.lineKey_) String? line,
  }) = _PhotographerTeaser;

  factory PhotographerTeaser.fromJson(Map<String, dynamic> json) =>
      _$PhotographerTeaserFromJson(json);

  static const String kindKey_ = r'kind';

  static const String lineKey_ = r'line';
}
