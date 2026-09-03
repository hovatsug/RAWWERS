// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_points_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CyclePointsView _$CyclePointsViewFromJson(Map<String, dynamic> json) =>
    _CyclePointsView(
      cycleId: json['cycle_id'] as String,
      userId: json['user_id'] as String,
      points: (json['points'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CyclePointsViewToJson(_CyclePointsView instance) =>
    <String, dynamic>{
      'cycle_id': instance.cycleId,
      'user_id': instance.userId,
      'points': instance.points,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
