// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardControllerHash() =>
    r'5d58127927226d142198914bd895d2b95ac5b771';

/// Refreshing the dashboard, in one place.
///
/// Every block on the screen watches a shared provider rather than fetching
/// its own copy, so this is what a pull-to-refresh drives. Two reasons it is
/// centralised rather than left to each block:
///
///   - `GET /v1/pro/me/skills` recomputes twelve niches and commits before it
///     returns anything (docs/BACKEND_GAPS.md). Seven blocks refreshing
///     independently would mean several rounds of that on one pull.
///   - The blocks are not independent. Price and bookable days are read off
///     the listing preview, which is also what renders the card, so a pricing
///     or availability change has to invalidate the preview or the card goes
///     stale while the section above it looks correct.
///
/// Copied from [DashboardController].
@ProviderFor(DashboardController)
final dashboardControllerProvider =
    AutoDisposeNotifierProvider<DashboardController, void>.internal(
      DashboardController.new,
      name: r'dashboardControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
