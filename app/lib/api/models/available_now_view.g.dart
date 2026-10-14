// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_now_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AvailableNowView _$AvailableNowViewFromJson(Map<String, dynamic> json) =>
    _AvailableNowView(
      switchedOn: json['switched_on'] as bool,
      availableUntil: json['available_until'] == null
          ? null
          : DateTime.parse(json['available_until'] as String),
      effective: json['effective'] as bool,
      prepMinutes: (json['prep_minutes'] as num).toInt(),
      prepOptionsMinutes: (json['prep_options_minutes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      eligiblePackageIds: (json['eligible_package_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastsHours: (json['lasts_hours'] as num).toInt(),
    );

Map<String, dynamic> _$AvailableNowViewToJson(_AvailableNowView instance) =>
    <String, dynamic>{
      'switched_on': instance.switchedOn,
      'available_until': instance.availableUntil?.toIso8601String(),
      'effective': instance.effective,
      'prep_minutes': instance.prepMinutes,
      'prep_options_minutes': instance.prepOptionsMinutes,
      'eligible_package_ids': instance.eligiblePackageIds,
      'lasts_hours': instance.lastsHours,
    };
