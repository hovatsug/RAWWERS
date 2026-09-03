/// ClientBookingRequestCreateRequest
/// {
///     "properties": {
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "niche_slug": {
///             "type": "string",
///             "title": "Niche Slug"
///         },
///         "date_window": {
///             "$ref": "#/components/schemas/BookingDateWindow"
///         },
///         "location": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Location"
///         },
///         "package_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Package Id"
///         },
///         "notes": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Notes"
///         },
///         "consent_level": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/GigConsentLevel"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         }
///     },
///     "type": "object",
///     "required": [
///         "pro_user_id",
///         "niche_slug",
///         "date_window",
///         "package_id"
///     ],
///     "title": "ClientBookingRequestCreateRequest"
/// }
library client_booking_request_create_request;

import 'exports.dart';
part 'client_booking_request_create_request.freezed.dart';
part 'client_booking_request_create_request.g.dart'; // ClientBookingRequestCreateRequest

@freezed
abstract class ClientBookingRequestCreateRequest
    with _$ClientBookingRequestCreateRequest {
  const ClientBookingRequestCreateRequest._();

  @jsonSerializable
  const factory ClientBookingRequestCreateRequest({
    /// proUserId
    @JsonKey(name: ClientBookingRequestCreateRequest.proUserIdKey_)
    required String proUserId,

    /// nicheSlug
    @JsonKey(name: ClientBookingRequestCreateRequest.nicheSlugKey_)
    required String nicheSlug,

    /// dateWindow
    @JsonKey(name: ClientBookingRequestCreateRequest.dateWindowKey_)
    required BookingDateWindow dateWindow,

    /// location
    @JsonKey(name: ClientBookingRequestCreateRequest.locationKey_)
    String? location,

    /// packageId
    @JsonKey(name: ClientBookingRequestCreateRequest.packageIdKey_)
    required String packageId,

    /// notes
    @JsonKey(name: ClientBookingRequestCreateRequest.notesKey_) String? notes,

    /// consentLevel
    @JsonKey(name: ClientBookingRequestCreateRequest.consentLevelKey_)
    GigConsentLevel? consentLevel,
  }) = _ClientBookingRequestCreateRequest;

  factory ClientBookingRequestCreateRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$ClientBookingRequestCreateRequestFromJson(json);

  static const String proUserIdKey_ = r'pro_user_id';

  static const String nicheSlugKey_ = r'niche_slug';

  static const String dateWindowKey_ = r'date_window';

  static const String locationKey_ = r'location';

  static const String packageIdKey_ = r'package_id';

  static const String notesKey_ = r'notes';

  static const String consentLevelKey_ = r'consent_level';
}
