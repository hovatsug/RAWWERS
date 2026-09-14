// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gig_invoice_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GigInvoiceListResponse _$GigInvoiceListResponseFromJson(
  Map<String, dynamic> json,
) => _GigInvoiceListResponse(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GigInvoiceView.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GigInvoiceListResponseToJson(
  _GigInvoiceListResponse instance,
) => <String, dynamic>{'items': instance.items};
