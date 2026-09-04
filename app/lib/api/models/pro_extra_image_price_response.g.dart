// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_extra_image_price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProExtraImagePriceResponse _$ProExtraImagePriceResponseFromJson(
  Map<String, dynamic> json,
) => _ProExtraImagePriceResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProExtraImagePriceRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProExtraImagePriceResponseToJson(
  _ProExtraImagePriceResponse instance,
) => <String, dynamic>{'items': instance.items};
