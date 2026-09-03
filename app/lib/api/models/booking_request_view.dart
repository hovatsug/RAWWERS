/// BookingRequestView
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
///         "expires_at"
///     ],
///     "title": "BookingRequestView"
/// }
library booking_request_view;

import 'exports.dart';
part 'booking_request_view.freezed.dart';
part 'booking_request_view.g.dart'; // BookingRequestView

@freezed
abstract class BookingRequestView with _$BookingRequestView {
  const BookingRequestView._();

  @jsonSerializable
  const factory BookingRequestView({
    /// id
    @JsonKey(name: BookingRequestView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: BookingRequestView.proUserIdKey_) required String proUserId,

    /// clientUserId
    @JsonKey(name: BookingRequestView.clientUserIdKey_)
    required String clientUserId,

    /// packageId
    @JsonKey(name: BookingRequestView.packageIdKey_) required String packageId,

    /// requestedStart
    @JsonKey(name: BookingRequestView.requestedStartKey_)
    required DateTime requestedStart,

    /// requestedEnd
    @JsonKey(name: BookingRequestView.requestedEndKey_)
    required DateTime requestedEnd,

    /// locationText
    @JsonKey(name: BookingRequestView.locationTextKey_) String? locationText,

    /// notes
    @JsonKey(name: BookingRequestView.notesKey_) String? notes,

    /// status
    @JsonKey(name: BookingRequestView.statusKey_)
    required BookingRequestStatus status,

    /// expiresAt
    @JsonKey(name: BookingRequestView.expiresAtKey_)
    required DateTime expiresAt,
  }) = _BookingRequestView;

  factory BookingRequestView.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestViewFromJson(json);

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
}
