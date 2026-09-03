/// ChatThreadView
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
///         "status": {
///             "$ref": "#/components/schemas/ChatThreadStatus"
///         },
///         "context_snapshot": {
///             "type": "object",
///             "title": "Context Snapshot"
///         },
///         "token_budget_used": {
///             "type": "integer",
///             "title": "Token Budget Used"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         },
///         "messages": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/ChatMessageView"
///             },
///             "title": "Messages"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "client_user_id",
///         "status",
///         "context_snapshot",
///         "token_budget_used",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "ChatThreadView"
/// }
library chat_thread_view;

import 'exports.dart';
part 'chat_thread_view.freezed.dart';
part 'chat_thread_view.g.dart'; // ChatThreadView

@freezed
abstract class ChatThreadView with _$ChatThreadView {
  const ChatThreadView._();

  @jsonSerializable
  const factory ChatThreadView({
    /// id
    @JsonKey(name: ChatThreadView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: ChatThreadView.proUserIdKey_) required String proUserId,

    /// clientUserId
    @JsonKey(name: ChatThreadView.clientUserIdKey_)
    required String clientUserId,

    /// status
    @JsonKey(name: ChatThreadView.statusKey_) required ChatThreadStatus status,

    /// contextSnapshot
    @JsonKey(name: ChatThreadView.contextSnapshotKey_)
    required Map<String, dynamic> contextSnapshot,

    /// tokenBudgetUsed
    @JsonKey(name: ChatThreadView.tokenBudgetUsedKey_)
    required int tokenBudgetUsed,

    /// createdAt
    @JsonKey(name: ChatThreadView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: ChatThreadView.updatedAtKey_) required DateTime updatedAt,

    /// messages
    @JsonKey(name: ChatThreadView.messagesKey_) List<ChatMessageView>? messages,
  }) = _ChatThreadView;

  factory ChatThreadView.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadViewFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String clientUserIdKey_ = r'client_user_id';

  static const String statusKey_ = r'status';

  static const String contextSnapshotKey_ = r'context_snapshot';

  static const String tokenBudgetUsedKey_ = r'token_budget_used';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';

  static const String messagesKey_ = r'messages';
}
