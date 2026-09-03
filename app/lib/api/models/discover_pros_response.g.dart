// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_pros_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiscoverProsResponse _$DiscoverProsResponseFromJson(
  Map<String, dynamic> json,
) => _DiscoverProsResponse(
  total: (json['total'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => ProCard.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DiscoverProsResponseToJson(
  _DiscoverProsResponse instance,
) => <String, dynamic>{'total': instance.total, 'items': instance.items};
