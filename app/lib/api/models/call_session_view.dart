/// CallSessionView
/// {
///     "properties": {
///         "id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Id"
///         },
///         "provider": {
///             "type": "string",
///             "title": "Provider"
///         },
///         "pro_user_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Pro User Id"
///         },
///         "recipient_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Recipient User Id"
///         },
///         "recipient_phone_e164": {
///             "type": "string",
///             "title": "Recipient Phone E164"
///         },
///         "purpose": {
///             "$ref": "#/components/schemas/CallPurpose"
///         },
///         "status": {
///             "$ref": "#/components/schemas/CallSessionStatus"
///         },
///         "provider_call_id": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Provider Call Id"
///         },
///         "outcome": {
///             "$ref": "#/components/schemas/CallOutcome"
///         },
///         "transcript": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Transcript"
///         },
///         "summary": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Summary"
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
///         }
///     },
///     "type": "object",
///     "required": [
///         "id",
///         "provider",
///         "recipient_user_id",
///         "recipient_phone_e164",
///         "purpose",
///         "status",
///         "outcome",
///         "created_at",
///         "updated_at"
///     ],
///     "title": "CallSessionView"
/// }
library call_session_view;

import 'exports.dart';
part 'call_session_view.freezed.dart';
part 'call_session_view.g.dart'; // CallSessionView

@freezed
abstract class CallSessionView with _$CallSessionView {
  const CallSessionView._();

  @jsonSerializable
  const factory CallSessionView({
    /// id
    @JsonKey(name: CallSessionView.idKey_) required String id,

    /// provider
    @JsonKey(name: CallSessionView.providerKey_) required String provider,

    /// proUserId
    @JsonKey(name: CallSessionView.proUserIdKey_) String? proUserId,

    /// recipientUserId
    @JsonKey(name: CallSessionView.recipientUserIdKey_)
    required String recipientUserId,

    /// recipientPhoneE164
    @JsonKey(name: CallSessionView.recipientPhoneE164Key_)
    required String recipientPhoneE164,

    /// purpose
    @JsonKey(name: CallSessionView.purposeKey_) required CallPurpose purpose,

    /// status
    @JsonKey(name: CallSessionView.statusKey_)
    required CallSessionStatus status,

    /// providerCallId
    @JsonKey(name: CallSessionView.providerCallIdKey_) String? providerCallId,

    /// outcome
    @JsonKey(name: CallSessionView.outcomeKey_) required CallOutcome outcome,

    /// transcript
    @JsonKey(name: CallSessionView.transcriptKey_) String? transcript,

    /// summary
    @JsonKey(name: CallSessionView.summaryKey_) String? summary,

    /// metadata
    @JsonKey(name: CallSessionView.metadataKey_) Map<String, dynamic>? metadata,

    /// createdAt
    @JsonKey(name: CallSessionView.createdAtKey_) required DateTime createdAt,

    /// updatedAt
    @JsonKey(name: CallSessionView.updatedAtKey_) required DateTime updatedAt,
  }) = _CallSessionView;

  factory CallSessionView.fromJson(Map<String, dynamic> json) =>
      _$CallSessionViewFromJson(json);

  static const String idKey_ = r'id';

  static const String providerKey_ = r'provider';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String recipientUserIdKey_ = r'recipient_user_id';

  static const String recipientPhoneE164Key_ = r'recipient_phone_e164';

  static const String purposeKey_ = r'purpose';

  static const String statusKey_ = r'status';

  static const String providerCallIdKey_ = r'provider_call_id';

  static const String outcomeKey_ = r'outcome';

  static const String transcriptKey_ = r'transcript';

  static const String summaryKey_ = r'summary';

  static const String metadataKey_ = r'metadata';

  static const String createdAtKey_ = r'created_at';

  static const String updatedAtKey_ = r'updated_at';
}
