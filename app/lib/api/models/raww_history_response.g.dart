// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raww_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawwHistoryResponse _$RawwHistoryResponseFromJson(Map<String, dynamic> json) =>
    _RawwHistoryResponse(
      total: (json['total'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => RawwEntryView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RawwHistoryResponseToJson(
  _RawwHistoryResponse instance,
) => <String, dynamic>{'total': instance.total, 'items': instance.items};
