/// ClientMatchCreateRequest
/// {
///     "properties": {
///         "country": {
///             "type": "string",
///             "title": "Country"
///         },
///         "city": {
///             "type": "string",
///             "title": "City"
///         },
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "budget_min": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Budget Min"
///         },
///         "budget_max": {
///             "anyOf": [
///                 {
///                     "type": "number"
///                 },
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Budget Max"
///         },
///         "style_tags": {
///             "type": "array",
///             "items": {
///                 "type": "string"
///             },
///             "title": "Style Tags"
///         }
///     },
///     "type": "object",
///     "required": [
///         "country",
///         "city",
///         "niche_slug"
///     ],
///     "title": "ClientMatchCreateRequest"
/// }
library client_match_create_request;

import 'exports.dart';
part 'client_match_create_request.freezed.dart';
part 'client_match_create_request.g.dart'; // ClientMatchCreateRequest

@freezed
abstract class ClientMatchCreateRequest with _$ClientMatchCreateRequest {
  const ClientMatchCreateRequest._();

  @jsonSerializable
  const factory ClientMatchCreateRequest({
    /// country
    @JsonKey(name: ClientMatchCreateRequest.countryKey_)
    required String country,

    /// city
    @JsonKey(name: ClientMatchCreateRequest.cityKey_) required String city,

    /// nicheSlug
    @JsonKey(name: ClientMatchCreateRequest.nicheSlugKey_)
    required String nicheSlug,

    /// budgetMin
    @JsonKey(name: ClientMatchCreateRequest.budgetMinKey_) dynamic? budgetMin,

    /// budgetMax
    @JsonKey(name: ClientMatchCreateRequest.budgetMaxKey_) dynamic? budgetMax,

    /// styleTags
    @JsonKey(name: ClientMatchCreateRequest.styleTagsKey_)
    List<String>? styleTags,
  }) = _ClientMatchCreateRequest;

  factory ClientMatchCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientMatchCreateRequestFromJson(json);

  static const String countryKey_ = r'country';

  static const String cityKey_ = r'city';

  static const String nicheSlugKey_ = r'niche_slug';

  static const String budgetMinKey_ = r'budget_min';

  static const String budgetMaxKey_ = r'budget_max';

  static const String styleTagsKey_ = r'style_tags';
}
