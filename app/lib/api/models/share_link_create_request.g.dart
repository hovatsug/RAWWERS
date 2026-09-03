// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShareLinkCreateRequest _$ShareLinkCreateRequestFromJson(
  Map<String, dynamic> json,
) => _ShareLinkCreateRequest(
  scope: ShareLinkScope.fromJson(json['scope'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  maxViews: (json['max_views'] as num?)?.toInt(),
  mediaAssetIds: (json['media_asset_ids'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ShareLinkCreateRequestToJson(
  _ShareLinkCreateRequest instance,
) => <String, dynamic>{
  'scope': instance.scope,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'max_views': instance.maxViews,
  'media_asset_ids': instance.mediaAssetIds,
};
