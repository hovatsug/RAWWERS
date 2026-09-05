/// CancelSlotRequest
/// {
///     "properties": {
///         "reason": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Reason"
///         }
///     },
///     "type": "object",
///     "title": "CancelSlotRequest"
/// }
library cancel_slot_request;

import 'exports.dart';
part 'cancel_slot_request.freezed.dart';
part 'cancel_slot_request.g.dart'; // CancelSlotRequest

@freezed
abstract class CancelSlotRequest with _$CancelSlotRequest {
  const CancelSlotRequest._();

  @jsonSerializable
  const factory CancelSlotRequest({
    /// reason
    @JsonKey(name: CancelSlotRequest.reasonKey_) String? reason,
  }) = _CancelSlotRequest;

  factory CancelSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelSlotRequestFromJson(json);

  static const String reasonKey_ = r'reason';
}
