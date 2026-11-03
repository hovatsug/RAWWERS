// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raww_pending_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RawwPendingBooking _$RawwPendingBookingFromJson(Map<String, dynamic> json) =>
    _RawwPendingBooking(
      gigId: json['gig_id'] as String,
      amount: (json['amount'] as num).toInt(),
      held: json['held'] as bool,
      expectedAt: json['expected_at'] == null
          ? null
          : DateTime.parse(json['expected_at'] as String),
    );

Map<String, dynamic> _$RawwPendingBookingToJson(_RawwPendingBooking instance) =>
    <String, dynamic>{
      'gig_id': instance.gigId,
      'amount': instance.amount,
      'held': instance.held,
      'expected_at': instance.expectedAt?.toIso8601String(),
    };
