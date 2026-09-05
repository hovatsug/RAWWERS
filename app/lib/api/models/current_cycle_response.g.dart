// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_cycle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurrentCycleResponse _$CurrentCycleResponseFromJson(
  Map<String, dynamic> json,
) => _CurrentCycleResponse(
  cycleId: json['cycle_id'] as String?,
  code: json['code'] as String?,
  name: json['name'] as String?,
  nameKey: json['name_key'] as String?,
  startAt: json['start_at'] == null
      ? null
      : DateTime.parse(json['start_at'] as String),
  endAt: json['end_at'] == null
      ? null
      : DateTime.parse(json['end_at'] as String),
  myPoints: (json['my_points'] as num?)?.toInt() ?? 0,
  leaderboard: (json['leaderboard'] as List<dynamic>?)
      ?.map((e) => CyclePointsView.fromJson(e as Map<String, dynamic>))
      .toList(),
  recentEvents: (json['recent_events'] as List<dynamic>?)
      ?.map((e) => CycleEventView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CurrentCycleResponseToJson(
  _CurrentCycleResponse instance,
) => <String, dynamic>{
  'cycle_id': instance.cycleId,
  'code': instance.code,
  'name': instance.name,
  'name_key': instance.nameKey,
  'start_at': instance.startAt?.toIso8601String(),
  'end_at': instance.endAt?.toIso8601String(),
  'my_points': instance.myPoints,
  'leaderboard': instance.leaderboard,
  'recent_events': instance.recentEvents,
};
