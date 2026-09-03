// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_session_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallSessionView _$CallSessionViewFromJson(Map<String, dynamic> json) =>
    _CallSessionView(
      id: json['id'] as String,
      provider: json['provider'] as String,
      proUserId: json['pro_user_id'] as String?,
      recipientUserId: json['recipient_user_id'] as String,
      recipientPhoneE164: json['recipient_phone_e164'] as String,
      purpose: CallPurpose.fromJson(json['purpose'] as String),
      status: CallSessionStatus.fromJson(json['status'] as String),
      providerCallId: json['provider_call_id'] as String?,
      outcome: CallOutcome.fromJson(json['outcome'] as String),
      transcript: json['transcript'] as String?,
      summary: json['summary'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CallSessionViewToJson(_CallSessionView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'pro_user_id': instance.proUserId,
      'recipient_user_id': instance.recipientUserId,
      'recipient_phone_e164': instance.recipientPhoneE164,
      'purpose': instance.purpose,
      'status': instance.status,
      'provider_call_id': instance.providerCallId,
      'outcome': instance.outcome,
      'transcript': instance.transcript,
      'summary': instance.summary,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
