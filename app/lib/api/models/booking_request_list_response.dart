/// BookingRequestListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/BookingRequestListItem"
///             },
///             "title": "Items"
///         },
///         "next_cursor": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Next Cursor"
///         }
///     },
///     "type": "object",
///     "title": "BookingRequestListResponse"
/// }
library booking_request_list_response;

import 'exports.dart';
part 'booking_request_list_response.freezed.dart';
part 'booking_request_list_response.g.dart'; // BookingRequestListResponse

@freezed
abstract class BookingRequestListResponse with _$BookingRequestListResponse {
  const BookingRequestListResponse._();

  @jsonSerializable
  const factory BookingRequestListResponse({
    /// items
    @JsonKey(name: BookingRequestListResponse.itemsKey_)
    List<BookingRequestListItem>? items,

    /// nextCursor
    @JsonKey(name: BookingRequestListResponse.nextCursorKey_)
    String? nextCursor,
  }) = _BookingRequestListResponse;

  factory BookingRequestListResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String nextCursorKey_ = r'next_cursor';
}
