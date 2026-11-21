// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_video_playback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresentationVideoPlayback _$PresentationVideoPlaybackFromJson(
  Map<String, dynamic> json,
) => _PresentationVideoPlayback(
  playbackUrl: json['playback_url'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$PresentationVideoPlaybackToJson(
  _PresentationVideoPlayback instance,
) => <String, dynamic>{
  'playback_url': instance.playbackUrl,
  'expires_in': instance.expiresIn,
};
