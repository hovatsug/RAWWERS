// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_floor_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GearFloorView _$GearFloorViewFromJson(Map<String, dynamic> json) =>
    _GearFloorView(
      meetsFloor: json['meets_floor'] as bool,
      hasFullFrameBody: json['has_full_frame_body'] as bool,
      hasQualifyingLens: json['has_qualifying_lens'] as bool,
      hasLighting: json['has_lighting'] as bool,
      lightingRequired: json['lighting_required'] as bool,
      lightingIsDeclared: json['lighting_is_declared'] as bool,
      awaitingReview: (json['awaiting_review'] as num).toInt(),
      missing: (json['missing'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GearFloorViewToJson(_GearFloorView instance) =>
    <String, dynamic>{
      'meets_floor': instance.meetsFloor,
      'has_full_frame_body': instance.hasFullFrameBody,
      'has_qualifying_lens': instance.hasQualifyingLens,
      'has_lighting': instance.hasLighting,
      'lighting_required': instance.lightingRequired,
      'lighting_is_declared': instance.lightingIsDeclared,
      'awaiting_review': instance.awaitingReview,
      'missing': instance.missing,
    };
