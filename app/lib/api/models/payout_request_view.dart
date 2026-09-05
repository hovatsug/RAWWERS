/// PayoutRequestView
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
///         "amount_eur": {
///             "type": "string",
///             "pattern": "^(?!^[-+.]*$)[+-]?0*\\d*\\.?\\d*$",
///             "title": "Amount Eur"
///         },
///         "status": {
///             "$ref": "#/components/schemas/PayoutRequestStatus"
///         },
///         "requested_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Requested At"
///         },
///         "approved_by_admin_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Approved By Admin Id"
///         },
///         "approved_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Approved At"
///         },
///         "paid_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Paid At"
///         },
///         "failure_reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Failure Reason"
///         },
///         "reference": {
///             "type": "object",
///             "title": "Reference"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "pro_user_id",
///         "amount_eur",
///         "status",
///         "requested_at",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "PayoutRequestView"
/// }
library payout_request_view;

import 'exports.dart';
part 'payout_request_view.freezed.dart';
part 'payout_request_view.g.dart'; // PayoutRequestView

@freezed
abstract class PayoutRequestView with _$PayoutRequestView {
  const PayoutRequestView._();

  @jsonSerializable
  const factory PayoutRequestView({
    /// id
    @JsonKey(name: PayoutRequestView.idKey_) required String id,

    /// proUserId
    @JsonKey(name: PayoutRequestView.proUserIdKey_) required String proUserId,

    /// amountEur
    @JsonKey(name: PayoutRequestView.amountEurKey_) required String amountEur,

    /// status
    @JsonKey(name: PayoutRequestView.statusKey_)
    required PayoutRequestStatus status,

    /// requestedAt
    @JsonKey(name: PayoutRequestView.requestedAtKey_)
    required DateTime requestedAt,

    /// approvedByAdminId
    @JsonKey(name: PayoutRequestView.approvedByAdminIdKey_)
    String? approvedByAdminId,

    /// approvedAt
    @JsonKey(name: PayoutRequestView.approvedAtKey_) DateTime? approvedAt,

    /// paidAt
    @JsonKey(name: PayoutRequestView.paidAtKey_) DateTime? paidAt,

    /// failureReason
    @JsonKey(name: PayoutRequestView.failureReasonKey_) String? failureReason,

    /// reference
    @JsonKey(name: PayoutRequestView.referenceKey_)
    Map<String, dynamic>? reference,

    /// createdAt
    @JsonKey(name: PayoutRequestView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: PayoutRequestView.updatedAtKey_) required DateTime updatedAt,
  }) = _PayoutRequestView;

  factory PayoutRequestView.fromJson(Map<String, dynamic> json) =>
      _$PayoutRequestViewFromJson(json);

  static const String idKey_ = r'id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String amountEurKey_ = r'amount_eur';

  static const String statusKey_ = r'status';

  static const String requestedAtKey_ = r'requested_at';

  static const String approvedByAdminIdKey_ = r'approved_by_admin_id';

  static const String approvedAtKey_ = r'approved_at';

  static const String paidAtKey_ = r'paid_at';

  static const String failureReasonKey_ = r'failure_reason';

  static const String referenceKey_ = r'reference';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
