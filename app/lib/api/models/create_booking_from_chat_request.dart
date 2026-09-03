/// CreateBookingFromChatRequest
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
///     "title": "CreateBookingFromChatRequest"
/// }
library create_booking_from_chat_request;

import 'exports.dart';
part 'create_booking_from_chat_request.freezed.dart';
part 'create_booking_from_chat_request.g.dart'; // CreateBookingFromChatRequest

@freezed
abstract class CreateBookingFromChatRequest
    with _$CreateBookingFromChatRequest {
  const CreateBookingFromChatRequest._();

  @jsonSerializable
  const factory CreateBookingFromChatRequest({
    /// packageId
    @JsonKey(name: CreateBookingFromChatRequest.packageIdKey_)
    required String packageId,

    /// requestedStart
    @JsonKey(name: CreateBookingFromChatRequest.requestedStartKey_)
    required DateTime requestedStart,

    /// requestedEnd
    @JsonKey(name: CreateBookingFromChatRequest.requestedEndKey_)
    required DateTime requestedEnd,

    /// locationText
    @JsonKey(name: CreateBookingFromChatRequest.locationTextKey_)
    String? locationText,

    /// notes
    @JsonKey(name: CreateBookingFromChatRequest.notesKey_) String? notes,
  }) = _CreateBookingFromChatRequest;

  factory CreateBookingFromChatRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingFromChatRequestFromJson(json);

  static const String packageIdKey_ = r'package_id';

  static const String requestedStartKey_ = r'requested_start';

  static const String requestedEndKey_ = r'requested_end';

  static const String locationTextKey_ = r'location_text';

  static const String notesKey_ = r'notes';
}
