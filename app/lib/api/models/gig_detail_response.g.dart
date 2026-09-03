// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigDetailResponse _$GigDetailResponseFromJson(Map<String, dynamic> json) =>
    _GigDetailResponse(
      gig: GigResponse.fromJson(json['gig'] as Map<String, dynamic>),
      payment: json['payment'] == null
          ? null
          : PaymentSummary.fromJson(json['payment'] as Map<String, dynamic>),
      ledgerSummary: LedgerSummary.fromJson(
        json['ledger_summary'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GigDetailResponseToJson(_GigDetailResponse instance) =>
    <String, dynamic>{
      'gig': instance.gig,
      'payment': instance.payment,
      'ledger_summary': instance.ledgerSummary,
    };
