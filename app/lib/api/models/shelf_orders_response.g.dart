// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_orders_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfOrdersResponse _$ShelfOrdersResponseFromJson(Map<String, dynamic> json) =>
    _ShelfOrdersResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => ShelfOrderView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShelfOrdersResponseToJson(
  _ShelfOrdersResponse instance,
) => <String, dynamic>{'items': instance.items};
