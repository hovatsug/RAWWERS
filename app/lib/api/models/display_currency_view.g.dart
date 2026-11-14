// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_currency_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DisplayCurrencyView _$DisplayCurrencyViewFromJson(Map<String, dynamic> json) =>
    _DisplayCurrencyView(
      displayCurrency: json['display_currency'] as String,
      chosen: json['chosen'] as bool,
      available: (json['available'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DisplayCurrencyViewToJson(
  _DisplayCurrencyView instance,
) => <String, dynamic>{
  'display_currency': instance.displayCurrency,
  'chosen': instance.chosen,
  'available': instance.available,
};
