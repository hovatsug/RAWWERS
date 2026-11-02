// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_marketing_agreement_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProMarketingAgreementView _$ProMarketingAgreementViewFromJson(
  Map<String, dynamic> json,
) => _ProMarketingAgreementView(
  optedIn: json['opted_in'] as bool,
  wordingVersion: json['wording_version'] as String,
  wordingText: json['wording_text'] as String,
  recordedAt: json['recorded_at'] == null
      ? null
      : DateTime.parse(json['recorded_at'] as String),
);

Map<String, dynamic> _$ProMarketingAgreementViewToJson(
  _ProMarketingAgreementView instance,
) => <String, dynamic>{
  'opted_in': instance.optedIn,
  'wording_version': instance.wordingVersion,
  'wording_text': instance.wordingText,
  'recorded_at': instance.recordedAt?.toIso8601String(),
};
