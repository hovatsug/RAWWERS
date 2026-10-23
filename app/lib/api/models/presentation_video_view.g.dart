// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_video_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresentationVideoView _$PresentationVideoViewFromJson(
  Map<String, dynamic> json,
) => _PresentationVideoView(
  playbackUrl: json['playback_url'] as String,
  posterUrl: json['poster_url'] as String?,
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$PresentationVideoViewToJson(
  _PresentationVideoView instance,
) => <String, dynamic>{
  'playback_url': instance.playbackUrl,
  'poster_url': instance.posterUrl,
  'duration_seconds': instance.durationSeconds,
};
