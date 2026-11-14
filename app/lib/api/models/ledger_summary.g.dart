// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LedgerSummary _$LedgerSummaryFromJson(Map<String, dynamic> json) =>
    _LedgerSummary(
      currency: json['currency'] as String,
      totalInflow: json['total_inflow'] as String,
      totalOutflow: json['total_outflow'] as String,
      net: json['net'] as String,
    );

Map<String, dynamic> _$LedgerSummaryToJson(_LedgerSummary instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'total_inflow': instance.totalInflow,
      'total_outflow': instance.totalOutflow,
      'net': instance.net,
    };
