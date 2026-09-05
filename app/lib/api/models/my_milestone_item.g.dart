// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_milestone_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyMilestoneItem _$MyMilestoneItemFromJson(Map<String, dynamic> json) =>
    _MyMilestoneItem(
      milestone: MilestoneView.fromJson(
        json['milestone'] as Map<String, dynamic>,
      ),
      progress: MilestoneProgressView.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$MyMilestoneItemToJson(_MyMilestoneItem instance) =>
    <String, dynamic>{
      'milestone': instance.milestone,
      'progress': instance.progress,
    };
