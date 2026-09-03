/// UpdateMyNichesRequest
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
///                 "$ref": "#/components/schemas/ProNicheInput"
///             },
///             "title": "Niches"
///         }
///     },
///     "type": "object",
///     "title": "UpdateMyNichesRequest"
/// }
library update_my_niches_request;

import 'exports.dart';
part 'update_my_niches_request.freezed.dart';
part 'update_my_niches_request.g.dart'; // UpdateMyNichesRequest

@freezed
abstract class UpdateMyNichesRequest with _$UpdateMyNichesRequest {
  const UpdateMyNichesRequest._();

  @jsonSerializable
  const factory UpdateMyNichesRequest({
    /// primaryNicheSlug
    @JsonKey(name: UpdateMyNichesRequest.primaryNicheSlugKey_)
    String? primaryNicheSlug,

    /// niches
    @JsonKey(name: UpdateMyNichesRequest.nichesKey_)
    List<ProNicheInput>? niches,
  }) = _UpdateMyNichesRequest;

  factory UpdateMyNichesRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyNichesRequestFromJson(json);

  static const String primaryNicheSlugKey_ = r'primary_niche_slug';

  static const String nichesKey_ = r'niches';
}
