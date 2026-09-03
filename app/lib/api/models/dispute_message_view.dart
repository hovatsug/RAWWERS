/// DisputeMessageView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "dispute_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Dispute Id"
///         },
///         "sender_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Sender User Id"
///         },
///         "message": {
///             "type": "string",
///             "title": "Message"
///         },
///         "evidence_media_asset_ids": {
///             "type": "array",
///             "items": {},
///             "title": "Evidence Media Asset Ids"
///         },
///         "created_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Created At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "dispute_id",
///         "sender_user_id",
///         "message",
///         "created_at"
///     ],
///     "title": "DisputeMessageView"
/// }
library dispute_message_view;

import 'exports.dart';
part 'dispute_message_view.freezed.dart';
part 'dispute_message_view.g.dart'; // DisputeMessageView

@freezed
abstract class DisputeMessageView with _$DisputeMessageView {
  const DisputeMessageView._();

  @jsonSerializable
  const factory DisputeMessageView({
    /// id
    @JsonKey(name: DisputeMessageView.idKey_) required String id,

    /// disputeId
    @JsonKey(name: DisputeMessageView.disputeIdKey_) required String disputeId,

    /// senderUserId
    @JsonKey(name: DisputeMessageView.senderUserIdKey_)
    required String senderUserId,

    /// message
    @JsonKey(name: DisputeMessageView.messageKey_) required String message,

    /// evidenceMediaAssetIds
    @JsonKey(name: DisputeMessageView.evidenceMediaAssetIdsKey_)
    List<dynamic>? evidenceMediaAssetIds,

    /// createdAt
    @JsonKey(name: DisputeMessageView.createdAtKey_)
    required DateTime createdAt,
  }) = _DisputeMessageView;

  factory DisputeMessageView.fromJson(Map<String, dynamic> json) =>
      _$DisputeMessageViewFromJson(json);

  static const String idKey_ = r'id';

  static const String disputeIdKey_ = r'dispute_id';

  static const String senderUserIdKey_ = r'sender_user_id';

  static const String messageKey_ = r'message';

  static const String evidenceMediaAssetIdsKey_ = r'evidence_media_asset_ids';

  static const String createdAtKey_ = r'created_at';
}
