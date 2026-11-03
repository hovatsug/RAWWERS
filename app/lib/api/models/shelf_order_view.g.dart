// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_order_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfOrderView _$ShelfOrderViewFromJson(Map<String, dynamic> json) =>
    _ShelfOrderView(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      title: json['title'] as String,
      priceRaww: (json['price_raww'] as num).toInt(),
      status: json['status'] as String,
      placedAt: DateTime.parse(json['placed_at'] as String),
      orderedAt: json['ordered_at'] == null
          ? null
          : DateTime.parse(json['ordered_at'] as String),
      shippedAt: json['shipped_at'] == null
          ? null
          : DateTime.parse(json['shipped_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      refundedAt: json['refunded_at'] == null
          ? null
          : DateTime.parse(json['refunded_at'] as String),
      trackingCode: json['tracking_code'] as String?,
      trackingUrl: json['tracking_url'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      canCancel: json['can_cancel'] as bool,
    );

Map<String, dynamic> _$ShelfOrderViewToJson(_ShelfOrderView instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'title': instance.title,
      'price_raww': instance.priceRaww,
      'status': instance.status,
      'placed_at': instance.placedAt.toIso8601String(),
      'ordered_at': instance.orderedAt?.toIso8601String(),
      'shipped_at': instance.shippedAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'refunded_at': instance.refundedAt?.toIso8601String(),
      'tracking_code': instance.trackingCode,
      'tracking_url': instance.trackingUrl,
      'cancel_reason': instance.cancelReason,
      'can_cancel': instance.canCancel,
    };
