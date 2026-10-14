// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_freshness.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$discoverReturnsHash() => r'8723d0647dce07d2ef5058781054e5ca755f836d';

/// Counts the times Discover came back into view: the app resumed, the
/// Discover tab was selected, or a page above it (a profile, a niche) was
/// popped. The home and niche controllers listen and fetch again when what
/// they hold is older than [discoverStaleAfter].
///
/// Copied from [DiscoverReturns].
@ProviderFor(DiscoverReturns)
final discoverReturnsProvider = NotifierProvider<DiscoverReturns, int>.internal(
  DiscoverReturns.new,
  name: r'discoverReturnsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$discoverReturnsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiscoverReturns = Notifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
