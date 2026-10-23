// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FindingView _$FindingViewFromJson(Map<String, dynamic> json) => _FindingView(
  id: json['id'] as String,
  gigId: json['gig_id'] as String,
  status: json['status'] as String,
  reason: json['reason'] as String,
  note: json['note'] as String,
  severe: json['severe'] as bool,
  createdAt: json['created_at'] as String,
  firstSeenAt: json['first_seen_at'] as String?,
  windowEndsAt: json['window_ends_at'] as String,
  response: json['response'] as String?,
  decisionNote: json['decision_note'] as String?,
  consequence: json['consequence'] as String?,
  strikeNumber: (json['strike_number'] as num?)?.toInt(),
);

Map<String, dynamic> _$FindingViewToJson(_FindingView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gig_id': instance.gigId,
      'status': instance.status,
      'reason': instance.reason,
      'note': instance.note,
      'severe': instance.severe,
      'created_at': instance.createdAt,
      'first_seen_at': instance.firstSeenAt,
      'window_ends_at': instance.windowEndsAt,
      'response': instance.response,
      'decision_note': instance.decisionNote,
      'consequence': instance.consequence,
      'strike_number': instance.strikeNumber,
    };
