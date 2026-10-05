/// GearFloorView
/// {
///     "properties": {
///         "meets_floor": {
///             "type": "boolean",
///             "title": "Meets Floor"
///         },
///         "has_full_frame_body": {
///             "type": "boolean",
///             "title": "Has Full Frame Body"
///         },
///         "has_qualifying_lens": {
///             "type": "boolean",
///             "title": "Has Qualifying Lens"
///         },
///         "has_lighting": {
///             "type": "boolean",
///             "title": "Has Lighting"
///         },
///         "lighting_required": {
///             "type": "boolean",
///             "title": "Lighting Required"
///         },
///         "lighting_is_declared": {
///             "type": "boolean",
///             "title": "Lighting Is Declared"
///         },
///         "awaiting_review": {
///             "type": "integer",
///             "title": "Awaiting Review"
///         },
///         "missing": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Missing"
///         }
///     },
///     "type": "object",
///     "required": [
///         "meets_floor",
///         "has_full_frame_body",
///         "has_qualifying_lens",
///         "has_lighting",
///         "lighting_required",
///         "lighting_is_declared",
///         "awaiting_review"
///     ],
///     "title": "GearFloorView",
///     "description": "Where the photographer stands against the floor, and what is left."
/// }
library gear_floor_view;

import 'exports.dart';
part 'gear_floor_view.freezed.dart';
part 'gear_floor_view.g.dart'; // GearFloorView

@freezed
abstract class GearFloorView with _$GearFloorView {
  const GearFloorView._();

  @jsonSerializable
  const factory GearFloorView({
    /// meetsFloor
    @JsonKey(name: GearFloorView.meetsFloorKey_) required bool meetsFloor,

    /// hasFullFrameBody
    @JsonKey(name: GearFloorView.hasFullFrameBodyKey_)
    required bool hasFullFrameBody,

    /// hasQualifyingLens
    @JsonKey(name: GearFloorView.hasQualifyingLensKey_)
    required bool hasQualifyingLens,

    /// hasLighting
    @JsonKey(name: GearFloorView.hasLightingKey_) required bool hasLighting,

    /// lightingRequired
    @JsonKey(name: GearFloorView.lightingRequiredKey_)
    required bool lightingRequired,

    /// lightingIsDeclared
    @JsonKey(name: GearFloorView.lightingIsDeclaredKey_)
    required bool lightingIsDeclared,

    /// awaitingReview
    @JsonKey(name: GearFloorView.awaitingReviewKey_)
    required int awaitingReview,

    /// missing
    @JsonKey(name: GearFloorView.missingKey_) List<String>? missing,
  }) = _GearFloorView;

  factory GearFloorView.fromJson(Map<String, dynamic> json) =>
      _$GearFloorViewFromJson(json);

  static const String meetsFloorKey_ = r'meets_floor';

  static const String hasFullFrameBodyKey_ = r'has_full_frame_body';

  static const String hasQualifyingLensKey_ = r'has_qualifying_lens';

  static const String hasLightingKey_ = r'has_lighting';

  static const String lightingRequiredKey_ = r'lighting_required';

  static const String lightingIsDeclaredKey_ = r'lighting_is_declared';

  static const String awaitingReviewKey_ = r'awaiting_review';

  static const String missingKey_ = r'missing';
}
