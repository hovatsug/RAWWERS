/// ProNicheInput
/// {
///     "properties": {
///         "slug": {
///             "type": "string",
///             "title": "Slug"
///         },
///         "declared_level": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/DeclaredLevel"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "is_primary": {
///             "type": "boolean",
///             "default": false,
///             "title": "Is Primary"
///         }
///     },
///     "type": "object",
///     "required": [
///         "slug"
///     ],
///     "title": "ProNicheInput"
/// }
library pro_niche_input;

import 'exports.dart';
part 'pro_niche_input.freezed.dart';
part 'pro_niche_input.g.dart'; // ProNicheInput

@freezed
abstract class ProNicheInput with _$ProNicheInput {
  const ProNicheInput._();

  @jsonSerializable
  const factory ProNicheInput({
    /// slug
    @JsonKey(name: ProNicheInput.slugKey_) required String slug,

    /// declaredLevel
    @JsonKey(name: ProNicheInput.declaredLevelKey_)
    DeclaredLevel? declaredLevel,

    /// isPrimary
    @Default(false) @JsonKey(name: ProNicheInput.isPrimaryKey_) bool isPrimary,
  }) = _ProNicheInput;

  factory ProNicheInput.fromJson(Map<String, dynamic> json) =>
      _$ProNicheInputFromJson(json);

  static const String slugKey_ = r'slug';

  static const String declaredLevelKey_ = r'declared_level';

  static const String isPrimaryKey_ = r'is_primary';
}
