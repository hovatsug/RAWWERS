// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientHomeResponse _$ClientHomeResponseFromJson(Map<String, dynamic> json) =>
    _ClientHomeResponse(
      rows: (json['rows'] as List<dynamic>?)
          ?.map((e) => ClientHomeRow.fromJson(e as Map<String, dynamic>))
          .toList(),
      guestLimited: json['guest_limited'] as bool? ?? false,
      niche: json['niche'] == null
          ? null
          : ClientHomeNiche.fromJson(json['niche'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClientHomeResponseToJson(_ClientHomeResponse instance) =>
    <String, dynamic>{
      'rows': instance.rows,
      'guest_limited': instance.guestLimited,
      'niche': instance.niche,
    };
