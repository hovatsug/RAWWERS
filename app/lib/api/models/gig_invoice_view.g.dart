// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_invoice_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigInvoiceView _$GigInvoiceViewFromJson(Map<String, dynamic> json) =>
    _GigInvoiceView(
      gigId: json['gig_id'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      currency: json['currency'] as String,
      clientTotal: json['client_total'] as String,
      platformRetained: json['platform_retained'] as String,
      proRaww: json['pro_raww'] as String,
      clientRaww: json['client_raww'] as String,
      proCash: json['pro_cash'] as String,
      retainedPercent: (json['retained_percent'] as num).toInt(),
      proRawwPercent: (json['pro_raww_percent'] as num).toInt(),
      clientCreditPercent: (json['client_credit_percent'] as num).toInt(),
      photosDelivered: (json['photos_delivered'] as num?)?.toInt(),
      ratesWereStamped: json['rates_were_stamped'] as bool? ?? true,
      vatStatus: json['vat_status'] as String? ?? 'not_answered',
      vatRatePercent: (json['vat_rate_percent'] as num?)?.toInt(),
      vatNumber: json['vat_number'] as String?,
      vatNetAmount: json['vat_net_amount'] as String?,
      vatAmount: json['vat_amount'] as String?,
      platformCommissionVat: json['platform_commission_vat'],
    );

Map<String, dynamic> _$GigInvoiceViewToJson(_GigInvoiceView instance) =>
    <String, dynamic>{
      'gig_id': instance.gigId,
      'issued_at': instance.issuedAt.toIso8601String(),
      'currency': instance.currency,
      'client_total': instance.clientTotal,
      'platform_retained': instance.platformRetained,
      'pro_raww': instance.proRaww,
      'client_raww': instance.clientRaww,
      'pro_cash': instance.proCash,
      'retained_percent': instance.retainedPercent,
      'pro_raww_percent': instance.proRawwPercent,
      'client_credit_percent': instance.clientCreditPercent,
      'photos_delivered': instance.photosDelivered,
      'rates_were_stamped': instance.ratesWereStamped,
      'vat_status': instance.vatStatus,
      'vat_rate_percent': instance.vatRatePercent,
      'vat_number': instance.vatNumber,
      'vat_net_amount': instance.vatNetAmount,
      'vat_amount': instance.vatAmount,
      'platform_commission_vat': instance.platformCommissionVat,
    };
