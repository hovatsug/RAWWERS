/// UpdateMyNichesResponse
/// {
///     "properties": {
///         "primary_niche_slug": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Primary Niche Slug"
///         },
///         "niches": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ProNicheView"
///             },
///             "title": "Niches"
///         }
///     },
///     "type": "object",
///     "title": "UpdateMyNichesResponse"
/// }
library update_my_niches_response;

import 'exports.dart';
part 'update_my_niches_response.freezed.dart';
part 'update_my_niches_response.g.dart'; // UpdateMyNichesResponse

@freezed
abstract class UpdateMyNichesResponse with _$UpdateMyNichesResponse {
  const UpdateMyNichesResponse._();

  @jsonSerializable
  const factory UpdateMyNichesResponse({
    /// primaryNicheSlug
    @JsonKey(name: UpdateMyNichesResponse.primaryNicheSlugKey_)
    String? primaryNicheSlug,

    /// niches
    @JsonKey(name: UpdateMyNichesResponse.nichesKey_)
    List<ProNicheView>? niches,
  }) = _UpdateMyNichesResponse;

  factory UpdateMyNichesResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyNichesResponseFromJson(json);

  static const String primaryNicheSlugKey_ = r'primary_niche_slug';

  static const String nichesKey_ = r'niches';
}
