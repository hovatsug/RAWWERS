// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_home_row.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientHomeRow _$ClientHomeRowFromJson(Map<String, dynamic> json) =>
    _ClientHomeRow(
      key: json['key'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ClientDiscoverCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      banner: json['banner'] == null
          ? null
          : NicheBannerView.fromJson(json['banner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientHomeRowToJson(_ClientHomeRow instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'items': instance.items,
      'banner': instance.banner,
    };
