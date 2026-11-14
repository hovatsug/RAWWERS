// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_credit_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingCreditPreview _$BookingCreditPreviewFromJson(
  Map<String, dynamic> json,
) => _BookingCreditPreview(
  balance: json['balance'] as String,
  creditCurrency: json['credit_currency'] as String,
  discount: json['discount'] as String,
  price: json['price'] as String,
  total: json['total'] as String,
  maxDiscountPercent: (json['max_discount_percent'] as num).toInt(),
  applied: json['applied'] as bool,
  currency: json['currency'] as String,
);

Map<String, dynamic> _$BookingCreditPreviewToJson(
  _BookingCreditPreview instance,
) => <String, dynamic>{
  'balance': instance.balance,
  'credit_currency': instance.creditCurrency,
  'discount': instance.discount,
  'price': instance.price,
  'total': instance.total,
  'max_discount_percent': instance.maxDiscountPercent,
  'applied': instance.applied,
  'currency': instance.currency,
};
