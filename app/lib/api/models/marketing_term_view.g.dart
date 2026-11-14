// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_term_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketingTermView _$MarketingTermViewFromJson(Map<String, dynamic> json) =>
    _MarketingTermView(
      months: (json['months'] as num).toInt(),
      credit: (json['credit'] as num).toInt(),
      creditAmount: json['credit_amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'EUR',
    );

Map<String, dynamic> _$MarketingTermViewToJson(_MarketingTermView instance) =>
    <String, dynamic>{
      'months': instance.months,
      'credit': instance.credit,
      'credit_amount': instance.creditAmount,
      'currency': instance.currency,
    };
