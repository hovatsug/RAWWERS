// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityTimezoneHash() =>
    r'd5c3a194ca5bf64b32d4ebb9f03dda569a0dac17';

/// The IANA timezone to send with every rule.
///
/// Not `DateTime.now().timeZoneName`: that returns an abbreviation like
/// "WEST", and the backend validates with ZoneInfo and 422s on it - every
/// save of working hours would have failed. Dart's core library has no IANA
/// name, so this prefers what the pro has already chosen (their existing
/// rules), then the timezone the backend keeps on their notification
/// preferences, which is a real zone name.
///
/// Copied from [availabilityTimezone].
@ProviderFor(availabilityTimezone)
final availabilityTimezoneProvider = AutoDisposeFutureProvider<String>.internal(
  availabilityTimezone,
  name: r'availabilityTimezoneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availabilityTimezoneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailabilityTimezoneRef = AutoDisposeFutureProviderRef<String>;
String _$workingHoursControllerHash() =>
    r'd0f587635f810e96f6f0e77d6aad5986d6c3c21c';

/// Weekly working hours.
///
/// Reads and writes /v1/pro/scheduling/* exclusively. The older
/// /v1/pro/me/availability/* pair is deprecated: it drops the timezone and
/// location mode it does not accept, so posting there silently resets them.
///
/// Copied from [WorkingHoursController].
@ProviderFor(WorkingHoursController)
final workingHoursControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      WorkingHoursController,
      List<AvailabilityRuleView>
    >.internal(
      WorkingHoursController.new,
      name: r'workingHoursControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workingHoursControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkingHoursController =
    AutoDisposeAsyncNotifier<List<AvailabilityRuleView>>;
String _$blockedTimeControllerHash() =>
    r'63e05cb9aadcb20922cefefd37a5b9deed4af5bc';

/// Days blocked off.
///
/// Writes ProAvailabilityException, which every booking path now enforces.
///
/// Copied from [BlockedTimeController].
@ProviderFor(BlockedTimeController)
final blockedTimeControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BlockedTimeController,
      List<AvailabilityExceptionView>
    >.internal(
      BlockedTimeController.new,
      name: r'blockedTimeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$blockedTimeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BlockedTimeController =
    AutoDisposeAsyncNotifier<List<AvailabilityExceptionView>>;
String _$schedulingPolicyControllerHash() =>
    r'a321ae2e807478298fec01f271be8448532a4a14';

/// Lead time and slot shape.
///
/// Copied from [SchedulingPolicyController].
@ProviderFor(SchedulingPolicyController)
final schedulingPolicyControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      SchedulingPolicyController,
      SchedulingPolicyView
    >.internal(
      SchedulingPolicyController.new,
      name: r'schedulingPolicyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$schedulingPolicyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SchedulingPolicyController =
    AutoDisposeAsyncNotifier<SchedulingPolicyView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
