/// CyclePointsView
/// {
///     "properties": {
///         "cycle_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "Cycle Id"
///         },
///         "user_id": {
///             "type": "string",
///             "format": "uuid",
///             "title": "User Id"
///         },
///         "points": {
///             "type": "integer",
///             "title": "Points"
///         },
///         "updated_at": {
///             "type": "string",
///             "format": "date-time",
///             "title": "Updated At"
///         }
///     },
///     "type": "object",
///     "required": [
///         "cycle_id",
///         "user_id",
///         "points",
///         "updated_at"
///     ],
///     "title": "CyclePointsView"
/// }
library cycle_points_view;

import 'exports.dart';
part 'cycle_points_view.freezed.dart';
part 'cycle_points_view.g.dart'; // CyclePointsView

@freezed
abstract class CyclePointsView with _$CyclePointsView {
  const CyclePointsView._();

  @jsonSerializable
  const factory CyclePointsView({
    /// cycleId
    @JsonKey(name: CyclePointsView.cycleIdKey_) required String cycleId,

    /// userId
    @JsonKey(name: CyclePointsView.userIdKey_) required String userId,

    /// points
    @JsonKey(name: CyclePointsView.pointsKey_) required int points,

    /// updatedAt
    @JsonKey(name: CyclePointsView.updatedAtKey_) required DateTime updatedAt,
  }) = _CyclePointsView;

  factory CyclePointsView.fromJson(Map<String, dynamic> json) =>
      _$CyclePointsViewFromJson(json);

  static const String cycleIdKey_ = r'cycle_id';

  static const String userIdKey_ = r'user_id';

  static const String pointsKey_ = r'points';

  static const String updatedAtKey_ = r'updated_at';
}
