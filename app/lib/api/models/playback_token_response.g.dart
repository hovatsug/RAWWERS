// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaybackTokenResponse _$PlaybackTokenResponseFromJson(
  Map<String, dynamic> json,
) => _PlaybackTokenResponse(
  token: json['token'] as String,
  playbackId: json['playback_id'] as String,
  expiresIn: (json['expires_in'] as num).toInt(),
);

Map<String, dynamic> _$PlaybackTokenResponseToJson(
  _PlaybackTokenResponse instance,
) => <String, dynamic>{
  'token': instance.token,
  'playback_id': instance.playbackId,
  'expires_in': instance.expiresIn,
};
