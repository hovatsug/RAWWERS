/// CurrentCycleResponse
/// {
///     "properties": {
///         "cycle_id": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "uuid"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Cycle Id"
///         },
///         "code": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Code"
///         },
///         "name": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Name"
///         },
///         "name_key": {
///             "anyOf": [
///                 {
///                     "type": "string"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Name Key"
///         },
///         "start_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "Start At"
///         },
///         "end_at": {
///             "anyOf": [
///                 {
///                     "type": "string",
///                     "format": "date-time"
///                 },
///                 {
///                     "type": "null"
///                 }
///             ],
///             "title": "End At"
///         },
///         "my_points": {
///             "type": "integer",
///             "default": 0,
///             "title": "My Points"
///         },
///         "leaderboard": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/CyclePointsView"
///             },
///             "title": "Leaderboard"
///         },
///         "recent_events": {
///             "type": "array",
///             "items": {
///                 "$ref": "#/components/schemas/CycleEventView"
///             },
///             "title": "Recent Events"
///         }
///     },
///     "type": "object",
///     "title": "CurrentCycleResponse"
/// }
library current_cycle_response;

import 'exports.dart';
part 'current_cycle_response.freezed.dart';
part 'current_cycle_response.g.dart'; // CurrentCycleResponse

@freezed
abstract class CurrentCycleResponse with _$CurrentCycleResponse {
  const CurrentCycleResponse._();

  @jsonSerializable
  const factory CurrentCycleResponse({
    /// cycleId
    @JsonKey(name: CurrentCycleResponse.cycleIdKey_) String? cycleId,

    /// code
    @JsonKey(name: CurrentCycleResponse.codeKey_) String? code,

    /// name
    @JsonKey(name: CurrentCycleResponse.nameKey_) String? name,

    /// nameKey
    @JsonKey(name: CurrentCycleResponse.nameKeyKey_) String? nameKey,

    /// startAt
    @JsonKey(name: CurrentCycleResponse.startAtKey_) DateTime? startAt,

    /// endAt
    @JsonKey(name: CurrentCycleResponse.endAtKey_) DateTime? endAt,

    /// myPoints
    @Default(0) @JsonKey(name: CurrentCycleResponse.myPointsKey_) int myPoints,

    /// leaderboard
    @JsonKey(name: CurrentCycleResponse.leaderboardKey_)
    List<CyclePointsView>? leaderboard,

    /// recentEvents
    @JsonKey(name: CurrentCycleResponse.recentEventsKey_)
    List<CycleEventView>? recentEvents,
  }) = _CurrentCycleResponse;

  factory CurrentCycleResponse.fromJson(Map<String, dynamic> json) =>
      _$CurrentCycleResponseFromJson(json);

  static const String cycleIdKey_ = r'cycle_id';

  static const String codeKey_ = r'code';

  static const String nameKey_ = r'name';

  static const String nameKeyKey_ = r'name_key';

  static const String startAtKey_ = r'start_at';

  static const String endAtKey_ = r'end_at';

  static const String myPointsKey_ = r'my_points';

  static const String leaderboardKey_ = r'leaderboard';

  static const String recentEventsKey_ = r'recent_events';
}
