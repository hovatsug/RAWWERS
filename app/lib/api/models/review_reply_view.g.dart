// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_reply_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewReplyView _$ReviewReplyViewFromJson(Map<String, dynamic> json) =>
    _ReviewReplyView(
      id: json['id'] as String,
      reviewId: json['review_id'] as String,
      proUserId: json['pro_user_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ReviewReplyViewToJson(_ReviewReplyView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'review_id': instance.reviewId,
      'pro_user_id': instance.proUserId,
      'text': instance.text,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
