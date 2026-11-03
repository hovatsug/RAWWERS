// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_raww_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProRawwView _$ProRawwViewFromJson(Map<String, dynamic> json) => _ProRawwView(
  shelfOpen: json['shelf_open'] as bool,
  spendable: (json['spendable'] as num).toInt(),
  pending: (json['pending'] as num).toInt(),
  rawwEurValue: json['raww_eur_value'] as String,
  pendingBookings: (json['pending_bookings'] as List<dynamic>)
      .map((e) => RawwPendingBooking.fromJson(e as Map<String, dynamic>))
      .toList(),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  expiryWarning: json['expiry_warning'] as bool,
  inactivityMonths: (json['inactivity_months'] as num).toInt(),
);

Map<String, dynamic> _$ProRawwViewToJson(_ProRawwView instance) =>
    <String, dynamic>{
      'shelf_open': instance.shelfOpen,
      'spendable': instance.spendable,
      'pending': instance.pending,
      'raww_eur_value': instance.rawwEurValue,
      'pending_bookings': instance.pendingBookings,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'expiry_warning': instance.expiryWarning,
      'inactivity_months': instance.inactivityMonths,
    };
