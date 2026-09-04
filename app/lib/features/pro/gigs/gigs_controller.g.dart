// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gigs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gigsFilterControllerHash() =>
    r'e8e8e3ecb27f379038f46aafa402485feca560c7';

/// See also [GigsFilterController].
@ProviderFor(GigsFilterController)
final gigsFilterControllerProvider =
    AutoDisposeNotifierProvider<GigsFilterController, GigsFilter>.internal(
      GigsFilterController.new,
      name: r'gigsFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gigsFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GigsFilterController = AutoDisposeNotifier<GigsFilter>;
String _$gigsControllerHash() => r'544ff810a0bae5332a2ec7eea0fa4efbdc6a58dc';

/// See also [GigsController].
@ProviderFor(GigsController)
final gigsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      GigsController,
      CursorPage<GigResponse>
    >.internal(
      GigsController.new,
      name: r'gigsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gigsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GigsController = AutoDisposeAsyncNotifier<CursorPage<GigResponse>>;
String _$todayControllerHash() => r'aab581e0eac088cdba8b6a6f7f5a6c2f0e46cb7a';

/// Gigs scheduled inside today, local time.
///
/// Bounds are computed from the device's local midnight and sent as UTC
/// instants, so "today" means the photographer's today rather than the
/// server's - a shoot at 09:00 in Lisbon should not appear on the wrong day
/// because the backend reasons in UTC.
///
/// Copied from [TodayController].
@ProviderFor(TodayController)
final todayControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      TodayController,
      CursorPage<GigResponse>
    >.internal(
      TodayController.new,
      name: r'todayControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodayController = AutoDisposeAsyncNotifier<CursorPage<GigResponse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
