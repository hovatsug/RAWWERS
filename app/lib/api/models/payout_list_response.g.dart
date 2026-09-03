// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutListResponse _$PayoutListResponseFromJson(Map<String, dynamic> json) =>
    _PayoutListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PayoutRequestView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PayoutListResponseToJson(_PayoutListResponse instance) =>
    <String, dynamic>{'items': instance.items};
