// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_create_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShareLinkCreateResponse _$ShareLinkCreateResponseFromJson(
  Map<String, dynamic> json,
) => _ShareLinkCreateResponse(
  id: json['id'] as String,
  token: json['token'] as String,
  shareUrl: json['share_url'] as String,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  maxViews: (json['max_views'] as num?)?.toInt(),
);

Map<String, dynamic> _$ShareLinkCreateResponseToJson(
  _ShareLinkCreateResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'share_url': instance.shareUrl,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'max_views': instance.maxViews,
};
