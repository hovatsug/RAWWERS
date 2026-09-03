/// MatchResponse
/// {
///     "properties": {
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/MatchCandidate"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "items"
///     ],
///     "title": "MatchResponse"
/// }
library match_response;

import 'exports.dart';
part 'match_response.freezed.dart';
part 'match_response.g.dart'; // MatchResponse

@freezed
abstract class MatchResponse with _$MatchResponse {
  const MatchResponse._();

  @jsonSerializable
  const factory MatchResponse({
    /// items
    @JsonKey(name: MatchResponse.itemsKey_) required List<MatchCandidate> items,
  }) = _MatchResponse;

  factory MatchResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchResponseFromJson(json);

  static const String itemsKey_ = r'items';
}
