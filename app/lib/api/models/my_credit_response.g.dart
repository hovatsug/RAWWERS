// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_credit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyCreditResponse _$MyCreditResponseFromJson(Map<String, dynamic> json) =>
    _MyCreditResponse(
      balanceEur: json['balance_eur'] as String,
      maxDiscountPercent: (json['max_discount_percent'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => CreditHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyCreditResponseToJson(_MyCreditResponse instance) =>
    <String, dynamic>{
      'balance_eur': instance.balanceEur,
      'max_discount_percent': instance.maxDiscountPercent,
      'items': instance.items,
    };
