// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_selection_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubmitSelectionResponse _$SubmitSelectionResponseFromJson(
  Map<String, dynamic> json,
) => _SubmitSelectionResponse(
  selectionId: json['selection_id'] as String,
  selectedCount: (json['selected_count'] as num).toInt(),
  includedPhotos: (json['included_photos'] as num).toInt(),
  extrasCount: (json['extras_count'] as num).toInt(),
  galleryStatus: ProofGalleryStatus.fromJson(json['gallery_status'] as String),
  upsellRequired: json['upsell_required'] as bool,
  paymentIntentId: json['payment_intent_id'] as String?,
  paymentIntentClientSecret: json['payment_intent_client_secret'] as String?,
  differenceRequired: json['difference_required'] as bool? ?? false,
  differenceAmount: json['difference_amount'] as String?,
  differencePaymentIntentId: json['difference_payment_intent_id'] as String?,
  differencePaymentIntentClientSecret:
      json['difference_payment_intent_client_secret'] as String?,
);

Map<String, dynamic> _$SubmitSelectionResponseToJson(
  _SubmitSelectionResponse instance,
) => <String, dynamic>{
  'selection_id': instance.selectionId,
  'selected_count': instance.selectedCount,
  'included_photos': instance.includedPhotos,
  'extras_count': instance.extrasCount,
  'gallery_status': instance.galleryStatus,
  'upsell_required': instance.upsellRequired,
  'payment_intent_id': instance.paymentIntentId,
  'payment_intent_client_secret': instance.paymentIntentClientSecret,
  'difference_required': instance.differenceRequired,
  'difference_amount': instance.differenceAmount,
  'difference_payment_intent_id': instance.differencePaymentIntentId,
  'difference_payment_intent_client_secret':
      instance.differencePaymentIntentClientSecret,
};
