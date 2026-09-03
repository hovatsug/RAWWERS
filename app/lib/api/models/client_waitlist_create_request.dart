/// ClientWaitlistCreateRequest
/// {
///     "properties": {
///         "email": {
///             "type": "string",
///             "title": "Email"
///         },
///         "country": {
///             "type": "string",
///             "title": "Country"
///         },
///         "city": {
///             "type": "string",
///             "title": "City"
///         },
///         "niche_slug": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Niche Slug"
///         }
///     },
///     "type": "object",
///     "required": [
///         "email",
///         "country",
///         "city"
///     ],
///     "title": "ClientWaitlistCreateRequest"
/// }
library client_waitlist_create_request;

import 'exports.dart';
part 'client_waitlist_create_request.freezed.dart';
part 'client_waitlist_create_request.g.dart'; // ClientWaitlistCreateRequest

@freezed
abstract class ClientWaitlistCreateRequest with _$ClientWaitlistCreateRequest {
  const ClientWaitlistCreateRequest._();

  @jsonSerializable
  const factory ClientWaitlistCreateRequest({
    /// email
    @JsonKey(name: ClientWaitlistCreateRequest.emailKey_) required String email,

    /// country
    @JsonKey(name: ClientWaitlistCreateRequest.countryKey_)
    required String country,

    /// city
    @JsonKey(name: ClientWaitlistCreateRequest.cityKey_) required String city,

    /// nicheSlug
    @JsonKey(name: ClientWaitlistCreateRequest.nicheSlugKey_) String? nicheSlug,
  }) = _ClientWaitlistCreateRequest;

  factory ClientWaitlistCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$ClientWaitlistCreateRequestFromJson(json);

  static const String emailKey_ = r'email';

  static const String countryKey_ = r'country';

  static const String cityKey_ = r'city';

  static const String nicheSlugKey_ = r'niche_slug';
}
