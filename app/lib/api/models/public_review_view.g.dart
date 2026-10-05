// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_review_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicReviewView _$PublicReviewViewFromJson(Map<String, dynamic> json) =>
    _PublicReviewView(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      text: json['text'] as String?,
      wouldBookAgain: json['would_book_again'] as bool,
      niche: ReviewNicheView.fromJson(json['niche'] as Map<String, dynamic>),
      videoPlaybackId: json['video_playback_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reply: json['reply'] == null
          ? null
          : ReviewReplyView.fromJson(json['reply'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PublicReviewViewToJson(_PublicReviewView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'text': instance.text,
      'would_book_again': instance.wouldBookAgain,
      'niche': instance.niche,
      'video_playback_id': instance.videoPlaybackId,
      'created_at': instance.createdAt.toIso8601String(),
      'reply': instance.reply,
    };
