/// BookingRequestCreateRequest
/// {
///     "properties": {
///         "package_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Package Id"
///         },
///         "requested_start": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Requested Start"
///         },
///         "requested_end": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Requested End"
///         },
///         "location_text": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Location Text"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "package_id",
///         "requested_start",
///         "requested_end"
///     ],
///     "title": "BookingRequestCreateRequest"
/// }
library booking_request_create_request;

import 'exports.dart';
part 'booking_request_create_request.freezed.dart';
part 'booking_request_create_request.g.dart'; // BookingRequestCreateRequest

@freezed
abstract class BookingRequestCreateRequest with _$BookingRequestCreateRequest {
  const BookingRequestCreateRequest._();

  @jsonSerializable
  const factory BookingRequestCreateRequest({
    /// packageId
    @JsonKey(name: BookingRequestCreateRequest.packageIdKey_)
    required String packageId,

    /// requestedStart
    @JsonKey(name: BookingRequestCreateRequest.requestedStartKey_)
    required DateTime requestedStart,

    /// requestedEnd
    @JsonKey(name: BookingRequestCreateRequest.requestedEndKey_)
    required DateTime requestedEnd,

    /// locationText
    @JsonKey(name: BookingRequestCreateRequest.locationTextKey_)
    String? locationText,

    /// notes
    @JsonKey(name: BookingRequestCreateRequest.notesKey_) String? notes,
  }) = _BookingRequestCreateRequest;

  factory BookingRequestCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestCreateRequestFromJson(json);

  static const String packageIdKey_ = r'package_id';

  static const String requestedStartKey_ = r'requested_start';

  static const String requestedEndKey_ = r'requested_end';

  static const String locationTextKey_ = r'location_text';

  static const String notesKey_ = r'notes';
}
