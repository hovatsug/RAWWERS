// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_booking_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClientBookingStatusResponse _$ClientBookingStatusResponseFromJson(
  Map<String, dynamic> json,
) => _ClientBookingStatusResponse(
  bookingId: json['booking_id'] as String,
  bookingStatus: json['booking_status'] as String,
  gigId: json['gig_id'] as String?,
  gigStatus: json['gig_status'] as String?,
  paymentStatus: json['payment_status'] as String?,
  proofGalleryId: json['proof_gallery_id'] as String?,
  proofGalleryStatus: json['proof_gallery_status'] as String?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  shortNotice: json['short_notice'] as bool? ?? false,
  refunds:
      (json['refunds'] as List<dynamic>?)
          ?.map((e) => ClientBookingRefund.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  payBy: json['pay_by'] == null
      ? null
      : DateTime.parse(json['pay_by'] as String),
  timeline: (json['timeline'] as List<dynamic>?)
      ?.map((e) => e as Map<String, dynamic>)
      .toList(),
  nextActions: (json['next_actions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  review: json['review'] == null
      ? null
      : ReviewView.fromJson(json['review'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClientBookingStatusResponseToJson(
  _ClientBookingStatusResponse instance,
) => <String, dynamic>{
  'booking_id': instance.bookingId,
  'booking_status': instance.bookingStatus,
  'gig_id': instance.gigId,
  'gig_status': instance.gigStatus,
  'payment_status': instance.paymentStatus,
  'proof_gallery_id': instance.proofGalleryId,
  'proof_gallery_status': instance.proofGalleryStatus,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'short_notice': instance.shortNotice,
  'refunds': instance.refunds,
  'pay_by': instance.payBy?.toIso8601String(),
  'timeline': instance.timeline,
  'next_actions': instance.nextActions,
  'review': instance.review,
};
