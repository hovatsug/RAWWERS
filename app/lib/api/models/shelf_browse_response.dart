/// ShelfBrowseResponse
/// {
///     "properties": {
///         "tier": {
///             "type": "string",
///             "title": "Tier"
///         },
///         "max_level": {
///             "type": "integer",
///             "title": "Max Level"
///         },
///         "spendable": {
///             "type": "integer",
///             "title": "Spendable"
///         },
///         "has_camera": {
///             "type": "boolean",
///             "title": "Has Camera"
///         },
///         "wishlist_max": {
///             "type": "integer",
///             "title": "Wishlist Max"
///         },
///         "terms_text": {
///             "type": "string",
///             "title": "Terms Text"
///         },
///         "terms_draft": {
///             "type": "boolean",
///             "title": "Terms Draft"
///         },
///         "levels": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ShelfBrowseLevel"
///             },
///             "title": "Levels"
///         }
///     },
///     "type": "object",
///     "required": [
///         "tier",
///         "max_level",
///         "spendable",
///         "has_camera",
///         "wishlist_max",
///         "terms_text",
///         "terms_draft",
///         "levels"
///     ],
///     "title": "ShelfBrowseResponse"
/// }
library shelf_browse_response;

import 'exports.dart';
part 'shelf_browse_response.freezed.dart';
part 'shelf_browse_response.g.dart'; // ShelfBrowseResponse

@freezed
abstract class ShelfBrowseResponse with _$ShelfBrowseResponse {
  const ShelfBrowseResponse._();

  @jsonSerializable
  const factory ShelfBrowseResponse({
    /// tier
    @JsonKey(name: ShelfBrowseResponse.tierKey_) required String tier,

    /// maxLevel
    @JsonKey(name: ShelfBrowseResponse.maxLevelKey_) required int maxLevel,

    /// spendable
    @JsonKey(name: ShelfBrowseResponse.spendableKey_) required int spendable,

    /// hasCamera
    @JsonKey(name: ShelfBrowseResponse.hasCameraKey_) required bool hasCamera,

    /// wishlistMax
    @JsonKey(name: ShelfBrowseResponse.wishlistMaxKey_)
    required int wishlistMax,

    /// termsText
    @JsonKey(name: ShelfBrowseResponse.termsTextKey_) required String termsText,

    /// termsDraft
    @JsonKey(name: ShelfBrowseResponse.termsDraftKey_) required bool termsDraft,

    /// levels
    @JsonKey(name: ShelfBrowseResponse.levelsKey_)
    required List<ShelfBrowseLevel> levels,
  }) = _ShelfBrowseResponse;

  factory ShelfBrowseResponse.fromJson(Map<String, dynamic> json) =>
      _$ShelfBrowseResponseFromJson(json);

  static const String tierKey_ = r'tier';

  static const String maxLevelKey_ = r'max_level';

  static const String spendableKey_ = r'spendable';

  static const String hasCameraKey_ = r'has_camera';

  static const String wishlistMaxKey_ = r'wishlist_max';

  static const String termsTextKey_ = r'terms_text';

  static const String termsDraftKey_ = r'terms_draft';

  static const String levelsKey_ = r'levels';
}
