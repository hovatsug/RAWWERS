// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectStatusResponse _$ConnectStatusResponseFromJson(
  Map<String, dynamic> json,
) => _ConnectStatusResponse(
  stripeAccountId: json['stripe_account_id'] as String?,
  accountStatus: json['account_status'] as String,
  chargesEnabled: json['charges_enabled'] as bool? ?? false,
  payoutsEnabled: json['payouts_enabled'] as bool? ?? false,
  detailsSubmitted: json['details_submitted'] as bool? ?? false,
  currentlyDue: (json['currently_due'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  pastDue: (json['past_due'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  disabledReason: json['disabled_reason'] as String?,
);

Map<String, dynamic> _$ConnectStatusResponseToJson(
  _ConnectStatusResponse instance,
) => <String, dynamic>{
  'stripe_account_id': instance.stripeAccountId,
  'account_status': instance.accountStatus,
  'charges_enabled': instance.chargesEnabled,
  'payouts_enabled': instance.payoutsEnabled,
  'details_submitted': instance.detailsSubmitted,
  'currently_due': instance.currentlyDue,
  'past_due': instance.pastDue,
  'disabled_reason': instance.disabledReason,
};
