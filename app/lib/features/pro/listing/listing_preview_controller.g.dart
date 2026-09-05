// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_preview_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$listingPreviewControllerHash() =>
    r'dcaeb932ee98297198ff8a10e50fe5707bb67fb1';

/// The pro's own listing, exactly as a client sees it.
///
/// The endpoint recomputes the discovery index before building the card,
/// and builds it with the same function that builds the Discover feed - so
/// this cannot drift from the real thing.
///
/// Watches the profile and package providers rather than only fetching
/// once: editing pricing has to visibly change the card, and that is only
/// true if changing a package invalidates this.
///
/// Copied from [ListingPreviewController].
@ProviderFor(ListingPreviewController)
final listingPreviewControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ListingPreviewController,
      ProListingPreviewResponse
    >.internal(
      ListingPreviewController.new,
      name: r'listingPreviewControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$listingPreviewControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ListingPreviewController =
    AutoDisposeAsyncNotifier<ProListingPreviewResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
