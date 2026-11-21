// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_presentation_video_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyPresentationVideoState _$MyPresentationVideoStateFromJson(
  Map<String, dynamic> json,
) => _MyPresentationVideoState(
  available: json['available'] as bool,
  message: json['message'] as String?,
  maxSeconds: (json['max_seconds'] as num).toInt(),
  maxBytes: (json['max_bytes'] as num).toInt(),
  shown: json['shown'] == null
      ? null
      : MyPresentationVideo.fromJson(json['shown'] as Map<String, dynamic>),
  pending: json['pending'] == null
      ? null
      : MyPresentationVideo.fromJson(json['pending'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MyPresentationVideoStateToJson(
  _MyPresentationVideoState instance,
) => <String, dynamic>{
  'available': instance.available,
  'message': instance.message,
  'max_seconds': instance.maxSeconds,
  'max_bytes': instance.maxBytes,
  'shown': instance.shown,
  'pending': instance.pending,
};
