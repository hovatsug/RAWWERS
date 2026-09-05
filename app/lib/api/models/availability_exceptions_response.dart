/// AvailabilityExceptionsResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/AvailabilityExceptionView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "title": "AvailabilityExceptionsResponse"
/// }
library availability_exceptions_response;

import 'exports.dart';
part 'availability_exceptions_response.freezed.dart';
part 'availability_exceptions_response.g.dart'; // AvailabilityExceptionsResponse

@freezed
abstract class AvailabilityExceptionsResponse
    with _$AvailabilityExceptionsResponse {
  const AvailabilityExceptionsResponse._();

  @jsonSerializable
  const factory AvailabilityExceptionsResponse({
    /// items
    @JsonKey(name: AvailabilityExceptionsResponse.itemsKey_)
    List<AvailabilityExceptionView>? items,
  }) = _AvailabilityExceptionsResponse;

  factory AvailabilityExceptionsResponse.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityExceptionsResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
