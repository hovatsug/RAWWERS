/// MyFindingsResponse
/// {
///     "properties": {
///         "strikes": {
///             "type": "integer",
///             "title": "Strikes"
///         },
///         "pause": {
///             "anyOf": [
///                 {
///                     "$ref": "#/components/schemas/BookingPauseView"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ]
///         },
///         "items": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/FindingView"
///             },
///             "title": "Items"
///         }
///     },
///     "type": "object",
///     "required": [
///         "strikes",
///         "items"
///     ],
///     "title": "MyFindingsResponse"
/// }
library my_findings_response;

import 'exports.dart';
part 'my_findings_response.freezed.dart';
part 'my_findings_response.g.dart'; // MyFindingsResponse

@freezed
abstract class MyFindingsResponse with _$MyFindingsResponse {
  const MyFindingsResponse._();

  @jsonSerializable
  const factory MyFindingsResponse({
    /// strikes
    @JsonKey(name: MyFindingsResponse.strikesKey_) required int strikes,

    /// pause
    @JsonKey(name: MyFindingsResponse.pauseKey_) BookingPauseView? pause,

    /// items
    @JsonKey(name: MyFindingsResponse.itemsKey_)
    required List<FindingView> items,
  }) = _MyFindingsResponse;

  factory MyFindingsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyFindingsResponseFromJson(json);

  static const String strikesKey_ = r'strikes';

  static const String pauseKey_ = r'pause';

  static const String itemsKey_ = r'items';
}
