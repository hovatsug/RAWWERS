// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_discover_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientDiscoverResponse _$ClientDiscoverResponseFromJson(
  Map<String, dynamic> json,
) => _ClientDiscoverResponse(
  total: (json['total'] as num).toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ClientDiscoverCard.fromJson(e as Map<String, dynamic>))
      .toList(),
  guestLimited: json['guest_limited'] as bool? ?? false,
);

Map<String, dynamic> _$ClientDiscoverResponseToJson(
  _ClientDiscoverResponse instance,
) => <String, dynamic>{
  'total': instance.total,
  'items': instance.items,
  'guest_limited': instance.guestLimited,
};
