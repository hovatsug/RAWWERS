// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingRequestListResponse _$BookingRequestListResponseFromJson(
  Map<String, dynamic> json,
) => _BookingRequestListResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => BookingRequestListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$BookingRequestListResponseToJson(
  _BookingRequestListResponse instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
};
