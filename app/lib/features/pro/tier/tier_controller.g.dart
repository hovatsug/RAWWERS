// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tier_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tierStandingsControllerHash() =>
    r'199398c63d4f33588e6150626bf1a38cd7319180';

/// Where the photographer stands, per niche they actually work in.
///
/// Two calls, deliberately joined here rather than rendered separately:
/// `GET /v1/pro/me/skills` returns a row for **every active niche** - twelve
/// today - regardless of what this photographer selected, because it
/// recomputes across all of them before selecting. Rendered literally, a new
/// photographer's home screen would open with twelve rookie cards for ten
/// niches they never chose. `GET /v1/pro/niches/mine` is what they actually
/// picked, so the intersection is what gets shown.
///
/// keepAlive because every dashboard block reads this one result. The skills
/// endpoint recomputes and commits on every call (see docs/BACKEND_GAPS.md),
/// so refetching it per block would turn one app launch into several rounds of
/// twelve-niche write work.
///
/// Copied from [TierStandingsController].
@ProviderFor(TierStandingsController)
final tierStandingsControllerProvider =
    AsyncNotifierProvider<TierStandingsController, TierStandings>.internal(
      TierStandingsController.new,
      name: r'tierStandingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$tierStandingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TierStandingsController = AsyncNotifier<TierStandings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
