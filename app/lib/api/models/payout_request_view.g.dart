// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_request_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutRequestView _$PayoutRequestViewFromJson(Map<String, dynamic> json) =>
    _PayoutRequestView(
      id: json['id'] as String,
      proUserId: json['pro_user_id'] as String,
      amountEur: json['amount_eur'] as String,
      status: PayoutRequestStatus.fromJson(json['status'] as String),
      requestedAt: DateTime.parse(json['requested_at'] as String),
      approvedByAdminId: json['approved_by_admin_id'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      failureReason: json['failure_reason'] as String?,
      reference: json['reference'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PayoutRequestViewToJson(_PayoutRequestView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pro_user_id': instance.proUserId,
      'amount_eur': instance.amountEur,
      'status': instance.status,
      'requested_at': instance.requestedAt.toIso8601String(),
      'approved_by_admin_id': instance.approvedByAdminId,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'failure_reason': instance.failureReason,
      'reference': instance.reference,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
