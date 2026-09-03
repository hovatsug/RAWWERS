// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_milestones_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyMilestonesResponse _$MyMilestonesResponseFromJson(
  Map<String, dynamic> json,
) => _MyMilestonesResponse(
  total: (json['total'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => MyMilestoneItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MyMilestonesResponseToJson(
  _MyMilestonesResponse instance,
) => <String, dynamic>{'total': instance.total, 'items': instance.items};
