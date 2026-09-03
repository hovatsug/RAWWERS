/// NotificationListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/NotificationView"
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
///     "required": [
///         "items"
///     ],
///     "title": "NotificationListResponse"
/// }
library notification_list_response;

import 'exports.dart';
part 'notification_list_response.freezed.dart';
part 'notification_list_response.g.dart'; // NotificationListResponse

@freezed
abstract class NotificationListResponse with _$NotificationListResponse {
  const NotificationListResponse._();

  @jsonSerializable
  const factory NotificationListResponse({
    /// items
    @JsonKey(name: NotificationListResponse.itemsKey_)
    required List<NotificationView> items,

    /// nextCursor
    @JsonKey(name: NotificationListResponse.nextCursorKey_) String? nextCursor,
  }) = _NotificationListResponse;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String nextCursorKey_ = r'next_cursor';
}
