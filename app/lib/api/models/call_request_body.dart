/// CallRequestBody
/// {
///     "properties": {
///         "recipient_user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Recipient User Id"
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
///         "purpose": {
///             "$ref": "#/components/schemas/CallPurpose"
///         },
///         "target_type": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Target Type"
///         },
///         "target_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Target Id"
///         },
///         "source": {
///             "type": "string",
///             "default": "in_app",
///             "title": "Source"
///         },
///         "metadata": {
///             "type": "object",
///             "title": "Metadata"
///         }
///     },
///     "type": "object",
///     "required": [
///         "recipient_user_id",
///         "purpose"
///     ],
///     "title": "CallRequestBody"
/// }
library call_request_body;

import 'exports.dart';
part 'call_request_body.freezed.dart';
part 'call_request_body.g.dart'; // CallRequestBody

@freezed
abstract class CallRequestBody with _$CallRequestBody {
  const CallRequestBody._();

  @jsonSerializable
  const factory CallRequestBody({
    /// recipientUserId
    @JsonKey(name: CallRequestBody.recipientUserIdKey_)
    required String recipientUserId,

    /// proUserId
    @JsonKey(name: CallRequestBody.proUserIdKey_) String? proUserId,

    /// purpose
    @JsonKey(name: CallRequestBody.purposeKey_) required CallPurpose purpose,

    /// targetType
    @JsonKey(name: CallRequestBody.targetTypeKey_) String? targetType,

    /// targetId
    @JsonKey(name: CallRequestBody.targetIdKey_) String? targetId,

    /// source
    @Default('in_app') @JsonKey(name: CallRequestBody.sourceKey_) String source,

    /// metadata
    @JsonKey(name: CallRequestBody.metadataKey_) Map<String, dynamic>? metadata,
  }) = _CallRequestBody;

  factory CallRequestBody.fromJson(Map<String, dynamic> json) =>
      _$CallRequestBodyFromJson(json);

  static const String recipientUserIdKey_ = r'recipient_user_id';

  static const String proUserIdKey_ = r'pro_user_id';

  static const String purposeKey_ = r'purpose';

  static const String targetTypeKey_ = r'target_type';

  static const String targetIdKey_ = r'target_id';

  static const String sourceKey_ = r'source';

  static const String metadataKey_ = r'metadata';
}
