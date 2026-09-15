// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_profile_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaxProfileUpdateRequest _$TaxProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => _TaxProfileUpdateRequest(
  vatStatus: json['vat_status'] as String,
  vatNumber: json['vat_number'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$TaxProfileUpdateRequestToJson(
  _TaxProfileUpdateRequest instance,
) => <String, dynamic>{
  'vat_status': instance.vatStatus,
  'vat_number': instance.vatNumber,
  'country': instance.country,
};
