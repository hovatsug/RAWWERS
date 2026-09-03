/// ProNicheView
/// {
///     "properties": {
///         "slug": {
///             "type": "string",
///             "title": "Slug"
///         },
///         "name": {
///             "type": "string",
///             "title": "Name"
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
///             "title": "Is Primary"
///         }
///     },
///     "type": "object",
///     "required": [
///         "slug",
///         "name",
///         "is_primary"
///     ],
///     "title": "ProNicheView"
/// }
library pro_niche_view;

import 'exports.dart';
part 'pro_niche_view.freezed.dart';
part 'pro_niche_view.g.dart'; // ProNicheView

@freezed
abstract class ProNicheView with _$ProNicheView {
  const ProNicheView._();

  @jsonSerializable
  const factory ProNicheView({
    /// slug
    @JsonKey(name: ProNicheView.slugKey_) required String slug,

    /// name
    @JsonKey(name: ProNicheView.nameKey_) required String name,

    /// declaredLevel
    @JsonKey(name: ProNicheView.declaredLevelKey_) DeclaredLevel? declaredLevel,

    /// isPrimary
    @JsonKey(name: ProNicheView.isPrimaryKey_) required bool isPrimary,
  }) = _ProNicheView;

  factory ProNicheView.fromJson(Map<String, dynamic> json) =>
      _$ProNicheViewFromJson(json);

  static const String slugKey_ = r'slug';

  static const String nameKey_ = r'name';

  static const String declaredLevelKey_ = r'declared_level';

  static const String isPrimaryKey_ = r'is_primary';
}
