// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_summary_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvoiceSummaryView _$InvoiceSummaryViewFromJson(Map<String, dynamic> json) =>
    _InvoiceSummaryView(
      bookings: (json['bookings'] as num).toInt(),
      gross: json['gross'] as String,
      platformFees: json['platform_fees'] as String,
      proRaww: json['pro_raww'] as String,
      clientRaww: json['client_raww'] as String,
      proCash: json['pro_cash'] as String,
      averageGross: json['average_gross'] as String?,
      reconstructed: (json['reconstructed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$InvoiceSummaryViewToJson(_InvoiceSummaryView instance) =>
    <String, dynamic>{
      'bookings': instance.bookings,
      'gross': instance.gross,
      'platform_fees': instance.platformFees,
      'pro_raww': instance.proRaww,
      'client_raww': instance.clientRaww,
      'pro_cash': instance.proCash,
      'average_gross': instance.averageGross,
      'reconstructed': instance.reconstructed,
    };
