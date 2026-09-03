// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_account_upsert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutAccountUpsertRequest _$PayoutAccountUpsertRequestFromJson(
  Map<String, dynamic> json,
) => _PayoutAccountUpsertRequest(
  payoutMethod: PayoutMethod.fromJson(json['payout_method'] as String),
  stripeConnectAccountId: json['stripe_connect_account_id'] as String?,
  bankDetailsEncrypted: json['bank_details_encrypted'] as Map<String, dynamic>?,
  status: json['status'] == null
      ? PayoutAccountStatus.pendingVerification
      : PayoutAccountStatus.fromJson(json['status'] as String),
);

Map<String, dynamic> _$PayoutAccountUpsertRequestToJson(
  _PayoutAccountUpsertRequest instance,
) => <String, dynamic>{
  'payout_method': instance.payoutMethod,
  'stripe_connect_account_id': instance.stripeConnectAccountId,
  'bank_details_encrypted': instance.bankDetailsEncrypted,
  'status': instance.status,
};
