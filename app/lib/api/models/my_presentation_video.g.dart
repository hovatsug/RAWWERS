// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_presentation_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyPresentationVideo _$MyPresentationVideoFromJson(Map<String, dynamic> json) =>
    _MyPresentationVideo(
      mediaAssetId: json['media_asset_id'] as String,
      status: json['status'] as String,
      posterUrl: json['poster_url'] as String?,
      playbackUrl: json['playback_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$MyPresentationVideoToJson(
  _MyPresentationVideo instance,
) => <String, dynamic>{
  'media_asset_id': instance.mediaAssetId,
  'status': instance.status,
  'poster_url': instance.posterUrl,
  'playback_url': instance.playbackUrl,
  'duration_seconds': instance.durationSeconds,
  'message': instance.message,
};
