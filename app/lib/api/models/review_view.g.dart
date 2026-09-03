// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewView _$ReviewViewFromJson(Map<String, dynamic> json) => _ReviewView(
  id: json['id'] as String,
  gigId: json['gig_id'] as String,
  proUserId: json['pro_user_id'] as String,
  clientUserId: json['client_user_id'] as String,
  nicheId: json['niche_id'] as String,
  rating: (json['rating'] as num).toInt(),
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  text: json['text'] as String?,
  wouldBookAgain: json['would_book_again'] as bool,
  videoMediaAssetId: json['video_media_asset_id'] as String?,
  videoPlaybackId: json['video_playback_id'] as String?,
  status: ReviewStatus.fromJson(json['status'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  reply: json['reply'] == null
      ? null
      : ReviewReplyView.fromJson(json['reply'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewViewToJson(_ReviewView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'pro_user_id': instance.proUserId,
      'client_user_id': instance.clientUserId,
      'niche_id': instance.nicheId,
      'rating': instance.rating,
      'tags': instance.tags,
      'text': instance.text,
      'would_book_again': instance.wouldBookAgain,
      'video_media_asset_id': instance.videoMediaAssetId,
      'video_playback_id': instance.videoPlaybackId,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'reply': instance.reply,
    };
