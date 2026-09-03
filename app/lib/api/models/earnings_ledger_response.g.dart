// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_ledger_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarningsLedgerResponse _$EarningsLedgerResponseFromJson(
  Map<String, dynamic> json,
) => _EarningsLedgerResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => EarningsLedgerItemView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EarningsLedgerResponseToJson(
  _EarningsLedgerResponse instance,
) => <String, dynamic>{'items': instance.items};
