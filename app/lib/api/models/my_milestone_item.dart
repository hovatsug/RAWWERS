/// MyMilestoneItem
/// {
///     "properties": {
///         "milestone": {
///             "$ref": "#/components/schemas/MilestoneView"
///         },
///         "progress": {
///             "$ref": "#/components/schemas/MilestoneProgressView"
///         }
///     },
///     "type": "object",
///     "required": [
///         "milestone",
///         "progress"
///     ],
///     "title": "MyMilestoneItem"
/// }
library my_milestone_item;

import 'exports.dart';
part 'my_milestone_item.freezed.dart';
part 'my_milestone_item.g.dart'; // MyMilestoneItem

@freezed
abstract class MyMilestoneItem with _$MyMilestoneItem {
  const MyMilestoneItem._();

  @jsonSerializable
  const factory MyMilestoneItem({
    /// milestone
    @JsonKey(name: MyMilestoneItem.milestoneKey_)
    required MilestoneView milestone,

    /// progress
    @JsonKey(name: MyMilestoneItem.progressKey_)
    required MilestoneProgressView progress,
  }) = _MyMilestoneItem;

  factory MyMilestoneItem.fromJson(Map<String, dynamic> json) =>
      _$MyMilestoneItemFromJson(json);

  static const String milestoneKey_ = r'milestone';

  static const String progressKey_ = r'progress';
}
