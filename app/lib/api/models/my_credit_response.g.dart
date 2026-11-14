// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_credit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MyCreditResponse _$MyCreditResponseFromJson(Map<String, dynamic> json) =>
    _MyCreditResponse(
      balance: json['balance'] as String,
      currency: json['currency'] as String,
      maxDiscountPercent: (json['max_discount_percent'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => CreditHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyCreditResponseToJson(_MyCreditResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
      'max_discount_percent': instance.maxDiscountPercent,
      'items': instance.items,
    };
