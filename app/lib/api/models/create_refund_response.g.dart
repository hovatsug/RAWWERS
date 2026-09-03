// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_refund_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateRefundResponse _$CreateRefundResponseFromJson(
  Map<String, dynamic> json,
) => _CreateRefundResponse(
  refundId: json['refund_id'] as String,
  status: json['status'] as String,
  refundIds:
      (json['refund_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$CreateRefundResponseToJson(
  _CreateRefundResponse instance,
) => <String, dynamic>{
  'refund_id': instance.refundId,
  'status': instance.status,
  'refund_ids': instance.refundIds,
};
