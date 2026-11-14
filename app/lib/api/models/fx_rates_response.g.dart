// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fx_rates_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FxRatesResponse _$FxRatesResponseFromJson(Map<String, dynamic> json) =>
    _FxRatesResponse(
      baseAA: json['base'] as String,
      rates: json['rates'] as Map<String, dynamic>,
      asOf: json['as_of'] == null
          ? null
          : DateTime.parse(json['as_of'] as String),
    );

Map<String, dynamic> _$FxRatesResponseToJson(_FxRatesResponse instance) =>
    <String, dynamic>{
      'base': instance.baseAA,
      'rates': instance.rates,
      'as_of': instance.asOf?.toIso8601String(),
    };
