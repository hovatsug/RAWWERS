/// BookingRequestListItem
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "pro_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Pro User Id"
///         },
///         "client_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Client User Id"
///         },
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
///         },
///         "status": {
///             "$ref": "#/components/schemas/BookingRequestStatus"
///         },
///         "expires_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Expires At"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "seconds_until_expiry": {
///             "anyOf": [
///                 {
///                     "type": "integer"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Seconds Until Expiry"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "client_user_id",
///         "package_id",
///         "requested_start",
///         "requested_end",
///         "status",
///         "expires_at",
///         "created_at"
///     ],
///     "title": "BookingRequestListItem",
///     "description": "A list row is the detail view plus the two fields a queue screen needs.\n\n`expires_at` is inherited from BookingRequestView and is the response\ndeadline: a pending request auto-declines when it passes (see\n`app.tasks.scheduled.expire_booking_requests`). `seconds_until_expiry`\nis derived here rather than left to the client because every client\nwould otherwise re-derive it against its own clock, and a phone with a\nskewed clock would show a photographer the wrong time remaining on the\none decision the product gives them a deadline for. It is negative once\nthe deadline has passed, and null for any request no longer pending -\na declined request has no countdown."
/// }
library booking_request_list_item;

import 'exports.dart';
part 'booking_request_list_item.freezed.dart';
part 'booking_request_list_item.g.dart'; // BookingRequestListItem

@freezed
abstract class BookingRequestListItem with _$BookingRequestListItem {
  const BookingRequestListItem._();

  @jsonSerializable
  const factory BookingRequestListItem({
    /// id
    @JsonKey(name: BookingRequestListItem.idKey_) required String id,

    /// proUserId
    @JsonKey(name: BookingRequestListItem.proUserIdKey_)
    required String proUserId,

    /// clientUserId
    @JsonKey(name: BookingRequestListItem.clientUserIdKey_)
    required String clientUserId,

    /// packageId
    @JsonKey(name: BookingRequestListItem.packageIdKey_)
    required String packageId,

    /// requestedStart
    @JsonKey(name: BookingRequestListItem.requestedStartKey_)
    required DateTime requestedStart,

    /// requestedEnd
    @JsonKey(name: BookingRequestListItem.requestedEndKey_)
    required DateTime requestedEnd,

    /// locationText
    @JsonKey(name: BookingRequestListItem.locationTextKey_)
    String? locationText,

    /// notes
    @JsonKey(name: BookingRequestListItem.notesKey_) String? notes,

    /// status
    @JsonKey(name: BookingRequestListItem.statusKey_)
    required BookingRequestStatus status,

    /// expiresAt
    @JsonKey(name: BookingRequestListItem.expiresAtKey_)
    required DateTime expiresAt,

    /// createdAt
    @JsonKey(name: BookingRequestListItem.createdAtKey_)
    required DateTime createdAt,

    /// secondsUntilExpiry
    @JsonKey(name: BookingRequestListItem.secondsUntilExpiryKey_)
    int? secondsUntilExpiry,
  }) = _BookingRequestListItem;

  factory BookingRequestListItem.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestListItemFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String packageIdKey_ = r'package_id';

  static const String requestedStartKey_ = r'requested_start';

  static const String requestedEndKey_ = r'requested_end';

  static const String locationTextKey_ = r'location_text';

  static const String notesKey_ = r'notes';

  static const String statusKey_ = r'status';

  static const String expiresAtKey_ = r'expires_at';

  static const String createdAtKey_ = r'created_at';

  static const String secondsUntilExpiryKey_ = r'seconds_until_expiry';
}
