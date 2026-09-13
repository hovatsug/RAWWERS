/// ClientProfileNiche
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
///         "tier": {
///             "$ref": "#/components/schemas/SkillTier"
///         },
///         "photo_count": {
///             "type": "integer",
///             "title": "Photo Count"
///         },
///         "description": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Description"
///         }
///     },
///     "type": "object",
///     "required": [
///         "slug",
///         "name",
///         "tier",
///         "photo_count"
///     ],
///     "title": "ClientProfileNiche",
///     "description": "One niche a photographer actually has work in.\n\nDerived from the tags on their portfolio rather than from their skill\nrows. `recompute_pro_niche_skills` writes a row for every active niche, so\nskills say nothing about where someone works - a tab list built from them\nwould offer twelve tabs, ten of them empty."
/// }
library client_profile_niche;

import 'exports.dart';
part 'client_profile_niche.freezed.dart';
part 'client_profile_niche.g.dart'; // ClientProfileNiche

@freezed
abstract class ClientProfileNiche with _$ClientProfileNiche {
  const ClientProfileNiche._();

  @jsonSerializable
  const factory ClientProfileNiche({
    /// slug
    @JsonKey(name: ClientProfileNiche.slugKey_) required String slug,

    /// name
    @JsonKey(name: ClientProfileNiche.nameKey_) required String name,

    /// tier
    @JsonKey(name: ClientProfileNiche.tierKey_) required SkillTier tier,

    /// photoCount
    @JsonKey(name: ClientProfileNiche.photoCountKey_) required int photoCount,

    /// description
    @JsonKey(name: ClientProfileNiche.descriptionKey_) String? description,
  }) = _ClientProfileNiche;

  factory ClientProfileNiche.fromJson(Map<String, dynamic> json) =>
      _$ClientProfileNicheFromJson(json);

  static const String slugKey_ = r'slug';

  static const String nameKey_ = r'name';

  static const String tierKey_ = r'tier';

  static const String photoCountKey_ = r'photo_count';

  static const String descriptionKey_ = r'description';
}
