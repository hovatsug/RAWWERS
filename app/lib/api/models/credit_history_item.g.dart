// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_history_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreditHistoryItem _$CreditHistoryItemFromJson(Map<String, dynamic> json) =>
    _CreditHistoryItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      kind: json['kind'] as String,
      amountEur: json['amount_eur'] as String,
      photographerFirstName: json['photographer_first_name'] as String?,
    );

Map<String, dynamic> _$CreditHistoryItemToJson(_CreditHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'kind': instance.kind,
      'amount_eur': instance.amountEur,
      'photographer_first_name': instance.photographerFirstName,
    };
