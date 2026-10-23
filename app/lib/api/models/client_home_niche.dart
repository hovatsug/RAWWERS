/// ClientHomeNiche
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
///         "banner": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/NicheBannerView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "required": [
///         "slug",
///         "name"
///     ],
///     "title": "ClientHomeNiche",
///     "description": "The niche a home response is narrowed to."
/// }
library client_home_niche;

import 'exports.dart';
part 'client_home_niche.freezed.dart';
part 'client_home_niche.g.dart'; // ClientHomeNiche

@freezed
abstract class ClientHomeNiche with _$ClientHomeNiche {
  const ClientHomeNiche._();

  @jsonSerializable
  const factory ClientHomeNiche({
    /// slug
    @JsonKey(name: ClientHomeNiche.slugKey_) required String slug,

    /// name
    @JsonKey(name: ClientHomeNiche.nameKey_) required String name,

    /// banner
    @JsonKey(name: ClientHomeNiche.bannerKey_) NicheBannerView? banner,
  }) = _ClientHomeNiche;

  factory ClientHomeNiche.fromJson(Map<String, dynamic> json) =>
      _$ClientHomeNicheFromJson(json);

  static const String slugKey_ = r'slug';

  static const String nameKey_ = r'name';

  static const String bannerKey_ = r'banner';
}
