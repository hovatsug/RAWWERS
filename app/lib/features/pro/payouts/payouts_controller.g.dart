// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payouts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$earningsBalanceControllerHash() =>
    r'0895460f93a4543f2f6edd57a49ff00f94163dac';

/// Where the money is, and whether it can leave.
///
/// Copied from [EarningsBalanceController].
@ProviderFor(EarningsBalanceController)
final earningsBalanceControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      EarningsBalanceController,
      EarningsBalanceView
    >.internal(
      EarningsBalanceController.new,
      name: r'earningsBalanceControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$earningsBalanceControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EarningsBalanceController =
    AutoDisposeAsyncNotifier<EarningsBalanceView>;
String _$connectStatusControllerHash() =>
    r'150845a007e7b239438ed2ea9e5e75ee84feac60';

/// Stripe Connect onboarding state.
///
/// Read live from Stripe rather than from our stored status: the
/// account.updated webhook is what normally moves it, and a dropped event
/// would leave a photographer at "pending" forever with nothing to tell
/// them why. Opening this screen reconciles it.
///
/// Copied from [ConnectStatusController].
@ProviderFor(ConnectStatusController)
final connectStatusControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ConnectStatusController,
      ConnectStatusResponse
    >.internal(
      ConnectStatusController.new,
      name: r'connectStatusControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectStatusControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConnectStatusController =
    AutoDisposeAsyncNotifier<ConnectStatusResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
