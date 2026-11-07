// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_credit_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookingCreditPreview _$BookingCreditPreviewFromJson(
  Map<String, dynamic> json,
) => _BookingCreditPreview(
  balanceEur: json['balance_eur'] as String,
  discountEur: json['discount_eur'] as String,
  priceEur: json['price_eur'] as String,
  totalEur: json['total_eur'] as String,
  maxDiscountPercent: (json['max_discount_percent'] as num).toInt(),
  applied: json['applied'] as bool,
  currency: json['currency'] as String,
);

Map<String, dynamic> _$BookingCreditPreviewToJson(
  _BookingCreditPreview instance,
) => <String, dynamic>{
  'balance_eur': instance.balanceEur,
  'discount_eur': instance.discountEur,
  'price_eur': instance.priceEur,
  'total_eur': instance.totalEur,
  'max_discount_percent': instance.maxDiscountPercent,
  'applied': instance.applied,
  'currency': instance.currency,
};
