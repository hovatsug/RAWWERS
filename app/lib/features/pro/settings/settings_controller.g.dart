// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$payoutAccountHash() => r'a7040dcc4f2187f25f87763045fe46e85e85e832';

/// Where payouts would land. Read-only here - entering bank details is
/// deferred (F-6), so this reports status rather than offering a form.
///
/// Copied from [payoutAccount].
@ProviderFor(payoutAccount)
final payoutAccountProvider =
    AutoDisposeFutureProvider<PayoutAccountView>.internal(
      payoutAccount,
      name: r'payoutAccountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$payoutAccountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PayoutAccountRef = AutoDisposeFutureProviderRef<PayoutAccountView>;
String _$proProfileControllerHash() =>
    r'a48ca6be49717c15a385555b5b8b2d7b61eec69d';

/// The pro profile, as Settings needs it: name, KYC state, whether the
/// listing is live.
///
/// Copied from [ProProfileController].
@ProviderFor(ProProfileController)
final proProfileControllerProvider =
    AsyncNotifierProvider<ProProfileController, ProProfileView>.internal(
      ProProfileController.new,
      name: r'proProfileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$proProfileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProProfileController = AsyncNotifier<ProProfileView>;
String _$notificationPreferencesControllerHash() =>
    r'65502ed3b445ea3acd4f44b30a9d7f61d3bf00be';

/// See also [NotificationPreferencesController].
@ProviderFor(NotificationPreferencesController)
final notificationPreferencesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationPreferencesController,
      NotificationPreferenceView
    >.internal(
      NotificationPreferencesController.new,
      name: r'notificationPreferencesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationPreferencesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationPreferencesController =
    AutoDisposeAsyncNotifier<NotificationPreferenceView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
