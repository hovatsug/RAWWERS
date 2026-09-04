// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_extra_image_price_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProExtraImagePriceUpdateRequest _$ProExtraImagePriceUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _ProExtraImagePriceUpdateRequest(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ProExtraImagePriceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProExtraImagePriceUpdateRequestToJson(
  _ProExtraImagePriceUpdateRequest instance,
) => <String, dynamic>{'items': instance.items};
