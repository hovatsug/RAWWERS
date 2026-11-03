// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_shelf_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceShelfOrderRequest _$PlaceShelfOrderRequestFromJson(
  Map<String, dynamic> json,
) => _PlaceShelfOrderRequest(
  itemId: json['item_id'] as String,
  clientRequestId: json['client_request_id'] as String,
);

Map<String, dynamic> _$PlaceShelfOrderRequestToJson(
  _PlaceShelfOrderRequest instance,
) => <String, dynamic>{
  'item_id': instance.itemId,
  'client_request_id': instance.clientRequestId,
};
