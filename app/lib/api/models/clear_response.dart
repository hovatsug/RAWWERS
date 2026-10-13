/// ClearResponse
/// {
///     "properties": {
///         "cleared": {
///             "type": "boolean",
///             "default": true,
///             "title": "Cleared"
///         }
///     },
///     "type": "object",
///     "title": "ClearResponse"
/// }
library clear_response;

import 'exports.dart';
part 'clear_response.freezed.dart';
part 'clear_response.g.dart'; // ClearResponse

@freezed
abstract class ClearResponse with _$ClearResponse {
  const ClearResponse._();

  @jsonSerializable
  const factory ClearResponse({
    /// cleared
    @Default(true) @JsonKey(name: ClearResponse.clearedKey_) bool cleared,
  }) = _ClearResponse;

  factory ClearResponse.fromJson(Map<String, dynamic> json) =>
      _$ClearResponseFromJson(json);

  static const String clearedKey_ = r'cleared';
}
