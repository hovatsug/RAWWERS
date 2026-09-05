/// ClientBookingListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ClientBookingListItem"
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
///     "title": "ClientBookingListResponse"
/// }
library client_booking_list_response;

import 'exports.dart';
part 'client_booking_list_response.freezed.dart';
part 'client_booking_list_response.g.dart'; // ClientBookingListResponse

@freezed
abstract class ClientBookingListResponse with _$ClientBookingListResponse {
  const ClientBookingListResponse._();

  @jsonSerializable
  const factory ClientBookingListResponse({
    /// items
    @JsonKey(name: ClientBookingListResponse.itemsKey_)
    List<ClientBookingListItem>? items,

    /// nextCursor
    @JsonKey(name: ClientBookingListResponse.nextCursorKey_) String? nextCursor,
  }) = _ClientBookingListResponse;

  factory ClientBookingListResponse.fromJson(Map<String, dynamic> json) =>
      _$ClientBookingListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String nextCursorKey_ = r'next_cursor';
}
