// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_profile_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaxProfileView _$TaxProfileViewFromJson(Map<String, dynamic> json) =>
    _TaxProfileView(
      vatStatus: json['vat_status'] as String,
      vatNumber: json['vat_number'] as String?,
      country: json['country'] as String?,
      taxName: json['tax_name'] as String?,
      standardRatePercent: (json['standard_rate_percent'] as num?)?.toInt(),
      registrationThreshold: json['registration_threshold'] as String?,
      thresholdCurrency: json['threshold_currency'] as String?,
      vatNumberFormat: json['vat_number_format'] as String?,
    );

Map<String, dynamic> _$TaxProfileViewToJson(_TaxProfileView instance) =>
    <String, dynamic>{
      'vat_status': instance.vatStatus,
      'vat_number': instance.vatNumber,
      'country': instance.country,
      'tax_name': instance.taxName,
      'standard_rate_percent': instance.standardRatePercent,
      'registration_threshold': instance.registrationThreshold,
      'threshold_currency': instance.thresholdCurrency,
      'vat_number_format': instance.vatNumberFormat,
    };
