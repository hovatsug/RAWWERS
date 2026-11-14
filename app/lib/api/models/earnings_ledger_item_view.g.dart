// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_ledger_item_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarningsLedgerItemView _$EarningsLedgerItemViewFromJson(
  Map<String, dynamic> json,
) => _EarningsLedgerItemView(
  id: json['id'] as String,
  sourceType: EarningsSourceType.fromJson(json['source_type'] as String),
  sourceId: json['source_id'] as String,
  currency: json['currency'] as String,
  gross: json['gross'] as String,
  platformFee: json['platform_fee'] as String,
  net: json['net'] as String,
  status: EarningsEntryStatus.fromJson(json['status'] as String),
  availableAt: DateTime.parse(json['available_at'] as String),
  reversedAt: json['reversed_at'] == null
      ? null
      : DateTime.parse(json['reversed_at'] as String),
  meta: json['meta'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EarningsLedgerItemViewToJson(
  _EarningsLedgerItemView instance,
) => <String, dynamic>{
  'id': instance.id,
  'source_type': instance.sourceType,
  'source_id': instance.sourceId,
  'currency': instance.currency,
  'gross': instance.gross,
  'platform_fee': instance.platformFee,
  'net': instance.net,
  'status': instance.status,
  'available_at': instance.availableAt.toIso8601String(),
  'reversed_at': instance.reversedAt?.toIso8601String(),
  'meta': instance.meta,
  'created_at': instance.createdAt.toIso8601String(),
};
