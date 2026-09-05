// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_detail_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeDetailView _$DisputeDetailViewFromJson(Map<String, dynamic> json) =>
    _DisputeDetailView(
      id: json['id'] as String,
      gigId: json['gig_id'] as String?,
      extraPurchaseId: json['extra_purchase_id'] as String?,
      openedByUserId: json['opened_by_user_id'] as String,
      againstUserId: json['against_user_id'] as String?,
      category: DisputeCategory.fromJson(json['category'] as String),
      status: DisputeStatus.fromJson(json['status'] as String),
      reason: json['reason'] as String,
      summary: json['summary'] as String,
      requestedRefundAmount: json['requested_refund_amount'] as String?,
      currency: json['currency'] as String,
      openedAt: DateTime.parse(json['opened_at'] as String),
      dueResponseAt: json['due_response_at'] == null
          ? null
          : DateTime.parse(json['due_response_at'] as String),
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolution: json['resolution'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => DisputeMessageView.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => DisputeEventView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DisputeDetailViewToJson(_DisputeDetailView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'extra_purchase_id': instance.extraPurchaseId,
      'opened_by_user_id': instance.openedByUserId,
      'against_user_id': instance.againstUserId,
      'category': instance.category,
      'status': instance.status,
      'reason': instance.reason,
      'summary': instance.summary,
      'requested_refund_amount': instance.requestedRefundAmount,
      'currency': instance.currency,
      'opened_at': instance.openedAt.toIso8601String(),
      'due_response_at': instance.dueResponseAt?.toIso8601String(),
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolution': instance.resolution,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
      'events': instance.events,
    };
