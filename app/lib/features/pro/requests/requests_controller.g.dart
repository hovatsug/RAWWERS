// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requests_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requestsFilterControllerHash() =>
    r'50f615d186654273cfb07953e0216316112d4f4c';

/// See also [RequestsFilterController].
@ProviderFor(RequestsFilterController)
final requestsFilterControllerProvider =
    AutoDisposeNotifierProvider<
      RequestsFilterController,
      RequestsFilter
    >.internal(
      RequestsFilterController.new,
      name: r'requestsFilterControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestsFilterControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RequestsFilterController = AutoDisposeNotifier<RequestsFilter>;
String _$requestsControllerHash() =>
    r'20c67a8cc4eec211bdae02180e87fa6636db2abd';

/// See also [RequestsController].
@ProviderFor(RequestsController)
final requestsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      RequestsController,
      CursorPage<BookingRequestListItem>
    >.internal(
      RequestsController.new,
      name: r'requestsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RequestsController =
    AutoDisposeAsyncNotifier<CursorPage<BookingRequestListItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
