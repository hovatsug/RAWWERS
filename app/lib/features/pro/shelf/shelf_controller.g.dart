// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shelfControllerHash() => r'6246ce3e98a771231dca17359c2ccb9f2e441b18';

/// The Shelf as this photographer sees it: levels, the items they can see
/// and the ones their tier has not unlocked yet, and their wish list.
///
/// Copied from [ShelfController].
@ProviderFor(ShelfController)
final shelfControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ShelfController,
      ShelfBrowseResponse
    >.internal(
      ShelfController.new,
      name: r'shelfControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shelfControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShelfController = AutoDisposeAsyncNotifier<ShelfBrowseResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
