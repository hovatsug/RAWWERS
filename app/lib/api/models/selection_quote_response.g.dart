// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_quote_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectionQuoteResponse _$SelectionQuoteResponseFromJson(
  Map<String, dynamic> json,
) => _SelectionQuoteResponse(
  selectedCount: (json['selected_count'] as num).toInt(),
  includedPhotos: (json['included_photos'] as num).toInt(),
  minimumPhotos: (json['minimum_photos'] as num).toInt(),
  currency: json['currency'] as String,
  amountTotal: json['amount_total'] as String,
  amountPaid: json['amount_paid'] as String,
  amountDue: json['amount_due'] as String,
  nextPhotoPrice: json['next_photo_price'] as String?,
  extrasCount: (json['extras_count'] as num).toInt(),
  canSubmit: json['can_submit'] as bool,
  photosStillNeeded: (json['photos_still_needed'] as num).toInt(),
);

Map<String, dynamic> _$SelectionQuoteResponseToJson(
  _SelectionQuoteResponse instance,
) => <String, dynamic>{
  'selected_count': instance.selectedCount,
  'included_photos': instance.includedPhotos,
  'minimum_photos': instance.minimumPhotos,
  'currency': instance.currency,
  'amount_total': instance.amountTotal,
  'amount_paid': instance.amountPaid,
  'amount_due': instance.amountDue,
  'next_photo_price': instance.nextPhotoPrice,
  'extras_count': instance.extrasCount,
  'can_submit': instance.canSubmit,
  'photos_still_needed': instance.photosStillNeeded,
};
