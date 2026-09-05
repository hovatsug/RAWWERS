// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingControllerHash() =>
    r'fb75ea22a3481bd667c448a69770e879e866a306';

/// Progress toward going live, read from the server every time.
///
/// Deliberately has no local notion of "which step am I on". The backend
/// already computes exactly that from real state, so a photographer who
/// gets halfway, closes the app for a week and comes back finds the
/// checklist where they left it - and a photographer who deletes six
/// portfolio photos sees the step reopen, which a stored step index would
/// never do.
///
/// Copied from [OnboardingController].
@ProviderFor(OnboardingController)
final onboardingControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      OnboardingController,
      ProOnboardingChecksResponse
    >.internal(
      OnboardingController.new,
      name: r'onboardingControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingController =
    AutoDisposeAsyncNotifier<ProOnboardingChecksResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
