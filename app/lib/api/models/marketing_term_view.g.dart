// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_term_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MarketingTermView _$MarketingTermViewFromJson(Map<String, dynamic> json) =>
    _MarketingTermView(
      months: (json['months'] as num).toInt(),
      credit: (json['credit'] as num).toInt(),
      creditEur: json['credit_eur'] as String? ?? '0.00',
    );

Map<String, dynamic> _$MarketingTermViewToJson(_MarketingTermView instance) =>
    <String, dynamic>{
      'months': instance.months,
      'credit': instance.credit,
      'credit_eur': instance.creditEur,
    };
