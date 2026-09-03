// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingListResponse _$ClientBookingListResponseFromJson(
  Map<String, dynamic> json,
) => _ClientBookingListResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ClientBookingListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$ClientBookingListResponseToJson(
  _ClientBookingListResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
};
