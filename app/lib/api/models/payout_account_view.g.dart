// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_account_view.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayoutAccountView _$PayoutAccountViewFromJson(Map<String, dynamic> json) =>
    _PayoutAccountView(
      proUserId: json['pro_user_id'] as String,
      payoutMethod: PayoutMethod.fromJson(json['payout_method'] as String),
      stripeConnectAccountId: json['stripe_connect_account_id'] as String?,
      bankDetailsEncrypted:
          json['bank_details_encrypted'] as Map<String, dynamic>?,
      status: PayoutAccountStatus.fromJson(json['status'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PayoutAccountViewToJson(_PayoutAccountView instance) =>
    <String, dynamic>{
      'pro_user_id': instance.proUserId,
      'payout_method': instance.payoutMethod,
      'stripe_connect_account_id': instance.stripeConnectAccountId,
      'bank_details_encrypted': instance.bankDetailsEncrypted,
      'status': instance.status,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
