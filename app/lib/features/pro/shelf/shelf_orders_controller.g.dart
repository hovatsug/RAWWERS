// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shelfAddressControllerHash() =>
    r'95a0e0d9477f4afcd80c24afb0cff319b6206233';

/// The photographer's saved address for The Shelf, and where it ships.
///
/// Copied from [ShelfAddressController].
@ProviderFor(ShelfAddressController)
final shelfAddressControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ShelfAddressController,
      ShelfAddressResponse
    >.internal(
      ShelfAddressController.new,
      name: r'shelfAddressControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shelfAddressControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShelfAddressController =
    AutoDisposeAsyncNotifier<ShelfAddressResponse>;
String _$shelfOrdersControllerHash() =>
    r'4863114e7b984e5d68398708f4656012bf5ca930';

/// My orders on The Shelf, newest first.
///
/// Kept alive: the checkout only reads it to place an order, and an
/// auto-disposed notifier could be gone before the order comes back.
///
/// Copied from [ShelfOrdersController].
@ProviderFor(ShelfOrdersController)
final shelfOrdersControllerProvider =
    AsyncNotifierProvider<ShelfOrdersController, List<ShelfOrderView>>.internal(
      ShelfOrdersController.new,
      name: r'shelfOrdersControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shelfOrdersControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ShelfOrdersController = AsyncNotifier<List<ShelfOrderView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
