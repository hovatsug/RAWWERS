// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$locationControllerHash() =>
    r'dbae9f08fecc7d032ab219a8e37aab6b000e6dc0';

/// The stored browse location, or null if the client hasn't set one.
///
/// Copied from [LocationController].
@ProviderFor(LocationController)
final locationControllerProvider =
    AsyncNotifierProvider<LocationController, BrowseLocation?>.internal(
      LocationController.new,
      name: r'locationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationController = AsyncNotifier<BrowseLocation?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
