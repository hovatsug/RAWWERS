// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_asset_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaAssetView _$MediaAssetViewFromJson(Map<String, dynamic> json) =>
    _MediaAssetView(
      id: json['id'] as String,
      ownerUserId: json['owner_user_id'] as String,
      kind: json['kind'] as String,
      purpose: json['purpose'] as String,
      provider: json['provider'] as String,
      status: json['status'] as String,
      visibility: json['visibility'] as String,
      contentType: json['content_type'] as String?,
      byteSize: (json['byte_size'] as num?)?.toInt(),
      meta: json['meta'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => MediaObjectView.fromJson(e as Map<String, dynamic>))
          .toList(),
      playbackId: json['playback_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      nicheTags: (json['niche_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MediaAssetViewToJson(_MediaAssetView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_user_id': instance.ownerUserId,
      'kind': instance.kind,
      'purpose': instance.purpose,
      'provider': instance.provider,
      'status': instance.status,
      'visibility': instance.visibility,
      'content_type': instance.contentType,
      'byte_size': instance.byteSize,
      'meta': instance.meta,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'variants': instance.variants,
      'playback_id': instance.playbackId,
      'is_public': instance.isPublic,
      'niche_tags': instance.nicheTags,
    };
