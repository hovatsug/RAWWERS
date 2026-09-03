// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisputeListResponse _$DisputeListResponseFromJson(Map<String, dynamic> json) =>
    _DisputeListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => DisputeDetailView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DisputeListResponseToJson(
  _DisputeListResponse instance,
) => <String, dynamic>{'items': instance.items};
