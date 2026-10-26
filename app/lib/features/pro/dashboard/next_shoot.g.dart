// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next_shoot.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nextShootHash() => r'555417150b994cd97cea7c2c739cf439192a1aae';

/// The photographer's next shoot: the soonest one still to happen, from the
/// same gigs list the Gigs tab reads (only those from now on). Null when
/// none is booked.
///
/// Copied from [nextShoot].
@ProviderFor(nextShoot)
final nextShootProvider = AutoDisposeFutureProvider<GigResponse?>.internal(
  nextShoot,
  name: r'nextShootProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextShootHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextShootRef = AutoDisposeFutureProviderRef<GigResponse?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
