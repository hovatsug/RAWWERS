// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_view_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShareLinkViewResponse _$ShareLinkViewResponseFromJson(
  Map<String, dynamic> json,
) => _ShareLinkViewResponse(
  gigId: json['gig_id'] as String,
  scope: ShareLinkScope.fromJson(json['scope'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  maxViews: (json['max_views'] as num?)?.toInt(),
  viewCount: (json['view_count'] as num).toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => SharedMediaItemView.fromJson(e as Map<String, dynamic>))
      .toList(),
  poweredByText: json['powered_by_text'] as String?,
  createGalleryCtaText: json['create_gallery_cta_text'] as String?,
  createGalleryCtaUrl: json['create_gallery_cta_url'] as String?,
);

Map<String, dynamic> _$ShareLinkViewResponseToJson(
  _ShareLinkViewResponse instance,
) => <String, dynamic>{
  'gig_id': instance.gigId,
  'scope': instance.scope,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'max_views': instance.maxViews,
  'view_count': instance.viewCount,
  'items': instance.items,
  'powered_by_text': instance.poweredByText,
  'create_gallery_cta_text': instance.createGalleryCtaText,
  'create_gallery_cta_url': instance.createGalleryCtaUrl,
};
