// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeControllerHash() => r'ca127273dab3a3e99602638e961d10e57aa7a1b7';

/// The browsing home screen.
///
/// Rows arrive composed by the server, titles included. That is deliberate
/// and not laziness: what belongs in a row is a fairness rule - what counts
/// as "new", why a row is absent rather than empty, and the prohibition on
/// quietly boosting newcomers into a row named for experience - and a rule
/// implemented in two places drifts. This app renders what it is given and
/// decides none of it.
///
/// The practical consequence is that this controller is almost empty, which
/// is the point. Any logic here would be a second opinion about fairness.
///
/// Copied from [HomeController].
@ProviderFor(HomeController)
final homeControllerProvider =
    AutoDisposeAsyncNotifierProvider<HomeController, HomeState>.internal(
      HomeController.new,
      name: r'homeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeController = AutoDisposeAsyncNotifier<HomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
