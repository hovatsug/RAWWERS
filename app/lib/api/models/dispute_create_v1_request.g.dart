// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_create_v1_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeCreateV1Request _$DisputeCreateV1RequestFromJson(
  Map<String, dynamic> json,
) => _DisputeCreateV1Request(
  gigId: json['gig_id'] as String?,
  extraPurchaseId: json['extra_purchase_id'] as String?,
  category: DisputeCategory.fromJson(json['category'] as String),
  reason: json['reason'] as String?,
  summary: json['summary'] as String?,
  requestedRefundAmount: json['requested_refund_amount'],
  currency: json['currency'] as String? ?? 'EUR',
);

Map<String, dynamic> _$DisputeCreateV1RequestToJson(
  _DisputeCreateV1Request instance,
) => <String, dynamic>{
  'gig_id': instance.gigId,
  'extra_purchase_id': instance.extraPurchaseId,
  'category': instance.category,
  'reason': instance.reason,
  'summary': instance.summary,
  'requested_refund_amount': instance.requestedRefundAmount,
  'currency': instance.currency,
};
