/// DisputeDetailView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "gig_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Gig Id"
///         },
///         "extra_purchase_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Extra Purchase Id"
///         },
///         "opened_by_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Opened By User Id"
///         },
///         "against_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Against User Id"
///         },
///         "category": {
///             "$ref": "#/components/schemas/DisputeCategory"
///         },
///         "status": {
///             "$ref": "#/components/schemas/DisputeStatus"
///         },
///         "reason": {
///             "type": "string",
///             "title": "Reason"
///         },
///         "summary": {
///             "type": "string",
///             "title": "Summary"
///         },
///         "requested_refund_amount": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Requested Refund Amount"
///         },
///         "currency": {
///             "type": "string",
///             "title": "Currency"
///         },
///         "opened_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Opened At"
///         },
///         "due_response_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Due Response At"
///         },
///         "resolved_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Resolved At"
///         },
///         "resolution": {
///             "type": "object",
///             "title": "Resolution"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
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
///                 "$ref": "#/components/schemas/DisputeMessageView"
///             },
///             "title": "Messages"
///         },
///         "events": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/DisputeEventView"
///             },
///             "title": "Events"
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "opened_by_user_id",
///         "category",
///         "status",
///         "reason",
///         "summary",
///         "currency",
///         "opened_at",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "DisputeDetailView"
/// }
library dispute_detail_view;

import 'exports.dart';
part 'dispute_detail_view.freezed.dart';
part 'dispute_detail_view.g.dart'; // DisputeDetailView

@freezed
abstract class DisputeDetailView with _$DisputeDetailView {
  const DisputeDetailView._();

  @jsonSerializable
  const factory DisputeDetailView({
    /// id
    @JsonKey(name: DisputeDetailView.idKey_) required String id,

    /// gigId
    @JsonKey(name: DisputeDetailView.gigIdKey_) String? gigId,

    /// extraPurchaseId
    @JsonKey(name: DisputeDetailView.extraPurchaseIdKey_)
    String? extraPurchaseId,

    /// openedByUserId
    @JsonKey(name: DisputeDetailView.openedByUserIdKey_)
    required String openedByUserId,

    /// againstUserId
    @JsonKey(name: DisputeDetailView.againstUserIdKey_) String? againstUserId,

    /// category
    @JsonKey(name: DisputeDetailView.categoryKey_)
    required DisputeCategory category,

    /// status
    @JsonKey(name: DisputeDetailView.statusKey_) required DisputeStatus status,

    /// reason
    @JsonKey(name: DisputeDetailView.reasonKey_) required String reason,

    /// summary
    @JsonKey(name: DisputeDetailView.summaryKey_) required String summary,

    /// requestedRefundAmount
    @JsonKey(name: DisputeDetailView.requestedRefundAmountKey_)
    String? requestedRefundAmount,

    /// currency
    @JsonKey(name: DisputeDetailView.currencyKey_) required String currency,

    /// openedAt
    @JsonKey(name: DisputeDetailView.openedAtKey_) required DateTime openedAt,

    /// dueResponseAt
    @JsonKey(name: DisputeDetailView.dueResponseAtKey_) DateTime? dueResponseAt,

    /// resolvedAt
    @JsonKey(name: DisputeDetailView.resolvedAtKey_) DateTime? resolvedAt,

    /// resolution
    @JsonKey(name: DisputeDetailView.resolutionKey_)
    Map<String, dynamic>? resolution,

    /// metadata
    @JsonKey(name: DisputeDetailView.metadataKey_)
    Map<String, dynamic>? metadata,

    /// createdAt
    @JsonKey(name: DisputeDetailView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: DisputeDetailView.updatedAtKey_) required DateTime updatedAt,

    /// messages
    @JsonKey(name: DisputeDetailView.messagesKey_)
    List<DisputeMessageView>? messages,

    /// events
    @JsonKey(name: DisputeDetailView.eventsKey_) List<DisputeEventView>? events,
  }) = _DisputeDetailView;

  factory DisputeDetailView.fromJson(Map<String, dynamic> json) =>
      _$DisputeDetailViewFromJson(json);

  static const String idKey_ = r'id';

  static const String gigIdKey_ = r'gig_id';

  static const String extraPurchaseIdKey_ = r'extra_purchase_id';

  static const String openedByUserIdKey_ = r'opened_by_user_id';

  static const String againstUserIdKey_ = r'against_user_id';

  static const String categoryKey_ = r'category';

  static const String statusKey_ = r'status';

  static const String reasonKey_ = r'reason';

  static const String summaryKey_ = r'summary';

  static const String requestedRefundAmountKey_ = r'requested_refund_amount';

  static const String currencyKey_ = r'currency';

  static const String openedAtKey_ = r'opened_at';

  static const String dueResponseAtKey_ = r'due_response_at';

  static const String resolvedAtKey_ = r'resolved_at';

  static const String resolutionKey_ = r'resolution';

  static const String metadataKey_ = r'metadata';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';

  static const String messagesKey_ = r'messages';

  static const String eventsKey_ = r'events';
}
