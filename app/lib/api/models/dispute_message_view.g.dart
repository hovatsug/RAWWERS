// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_message_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeMessageView _$DisputeMessageViewFromJson(Map<String, dynamic> json) =>
    _DisputeMessageView(
      id: json['id'] as String,
      disputeId: json['dispute_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      message: json['message'] as String,
      evidenceMediaAssetIds: json['evidence_media_asset_ids'] as List<dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DisputeMessageViewToJson(_DisputeMessageView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dispute_id': instance.disputeId,
      'sender_user_id': instance.senderUserId,
      'message': instance.message,
      'evidence_media_asset_ids': instance.evidenceMediaAssetIds,
      'created_at': instance.createdAt.toIso8601String(),
    };
