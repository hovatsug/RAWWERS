/// ShelfBrowseLevel
/// {
///     "properties": {
///         "level": {
///             "type": "integer",
///             "title": "Level"
///         },
///         "band_raww": {
///             "type": "integer",
///             "title": "Band Raww"
///         },
///         "band_eur": {
///             "type": "string",
///             "default": "0.00",
///             "title": "Band Eur"
///         },
///         "locked": {
///             "type": "boolean",
///             "title": "Locked"
///         },
///         "unlocks_at_tier": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Unlocks At Tier"
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ShelfBrowseItem"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "level",
///         "band_raww",
///         "locked",
///         "items"
///     ],
///     "title": "ShelfBrowseLevel"
/// }
library shelf_browse_level;

import 'exports.dart';
part 'shelf_browse_level.freezed.dart';
part 'shelf_browse_level.g.dart'; // ShelfBrowseLevel

@freezed
abstract class ShelfBrowseLevel with _$ShelfBrowseLevel {
  const ShelfBrowseLevel._();

  @jsonSerializable
  const factory ShelfBrowseLevel({
    /// level
    @JsonKey(name: ShelfBrowseLevel.levelKey_) required int level,

    /// bandRaww
    @JsonKey(name: ShelfBrowseLevel.bandRawwKey_) required int bandRaww,

    /// bandEur
    @Default('0.00')
    @JsonKey(name: ShelfBrowseLevel.bandEurKey_)
    String bandEur,

    /// locked
    @JsonKey(name: ShelfBrowseLevel.lockedKey_) required bool locked,

    /// unlocksAtTier
    @JsonKey(name: ShelfBrowseLevel.unlocksAtTierKey_) String? unlocksAtTier,

    /// items
    @JsonKey(name: ShelfBrowseLevel.itemsKey_)
    required List<ShelfBrowseItem> items,
  }) = _ShelfBrowseLevel;

  factory ShelfBrowseLevel.fromJson(Map<String, dynamic> json) =>
      _$ShelfBrowseLevelFromJson(json);

  static const String levelKey_ = r'level';

  static const String bandRawwKey_ = r'band_raww';

  static const String bandEurKey_ = r'band_eur';

  static const String lockedKey_ = r'locked';

  static const String unlocksAtTierKey_ = r'unlocks_at_tier';

  static const String itemsKey_ = r'items';
}
