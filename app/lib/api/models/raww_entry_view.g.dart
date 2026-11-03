// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raww_entry_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawwEntryView _$RawwEntryViewFromJson(Map<String, dynamic> json) =>
    _RawwEntryView(
      id: json['id'] as String,
      kind: json['kind'] as String,
      amount: (json['amount'] as num).toInt(),
      status: json['status'] as String,
      gigId: json['gig_id'] as String?,
      sourceType: json['source_type'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RawwEntryViewToJson(_RawwEntryView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind,
      'amount': instance.amount,
      'status': instance.status,
      'gig_id': instance.gigId,
      'source_type': instance.sourceType,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };
