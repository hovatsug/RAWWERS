/// ChatThreadListResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ChatThreadSummary"
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
///     "title": "ChatThreadListResponse",
///     "description": "Cursor-paginated thread list, matching the convention in\n`app.services.pagination` used by the other collection routes.\n\nNote the existing `GET /v1/pro/chat/threads` predates that convention and\nstill returns a bare array capped at 200 with no cursor. It is left alone\nhere rather than changed underneath the web app, which consumes it."
/// }
library chat_thread_list_response;

import 'exports.dart';
part 'chat_thread_list_response.freezed.dart';
part 'chat_thread_list_response.g.dart'; // ChatThreadListResponse

@freezed
abstract class ChatThreadListResponse with _$ChatThreadListResponse {
  const ChatThreadListResponse._();

  @jsonSerializable
  const factory ChatThreadListResponse({
    /// items
    @JsonKey(name: ChatThreadListResponse.itemsKey_)
    List<ChatThreadSummary>? items,

    /// nextCursor
    @JsonKey(name: ChatThreadListResponse.nextCursorKey_) String? nextCursor,
  }) = _ChatThreadListResponse;

  factory ChatThreadListResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadListResponseFromJson(json);

  static const String itemsKey_ = r'items';

  static const String nextCursorKey_ = r'next_cursor';
}
