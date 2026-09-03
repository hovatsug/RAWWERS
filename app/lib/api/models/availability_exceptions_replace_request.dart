/// AvailabilityExceptionsReplaceRequest
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/AvailabilityExceptionItem"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "AvailabilityExceptionsReplaceRequest"
/// }
library availability_exceptions_replace_request;

import 'exports.dart';
part 'availability_exceptions_replace_request.freezed.dart';
part 'availability_exceptions_replace_request.g.dart'; // AvailabilityExceptionsReplaceRequest

@freezed
abstract class AvailabilityExceptionsReplaceRequest
    with _$AvailabilityExceptionsReplaceRequest {
  const AvailabilityExceptionsReplaceRequest._();

  @jsonSerializable
  const factory AvailabilityExceptionsReplaceRequest({
    /// items
    @JsonKey(name: AvailabilityExceptionsReplaceRequest.itemsKey_)
    List<AvailabilityExceptionItem>? items,
  }) = _AvailabilityExceptionsReplaceRequest;

  factory AvailabilityExceptionsReplaceRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$AvailabilityExceptionsReplaceRequestFromJson(json);

  static const String itemsKey_ = r'items';
}
