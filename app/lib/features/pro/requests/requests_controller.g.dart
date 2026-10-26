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
    r'a80831f987b7754540de9d1592f690b163b3e0df';

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
String _$pendingRequestsControllerHash() =>
    r'd2d8a67ee939cae0d5981b6dfdef94b4992063a4';

/// Requests waiting on the photographer, for the Requests tab's badge.
///
/// Polled every 30 seconds while the app is running: with no push yet, this
/// is how a photographer with the app open learns a request arrived - and a
/// short-notice one has only 30 minutes to be answered. Read from the first
/// page of the same pending list the tab shows, so the two cannot disagree;
/// a request past its deadline that the sweep has not reached yet is not
/// counted. When the count changes the list is refetched too, so a new
/// request is already there when the tab is opened.
///
/// Copied from [PendingRequestsController].
@ProviderFor(PendingRequestsController)
final pendingRequestsControllerProvider =
    AsyncNotifierProvider<PendingRequestsController, PendingRequests>.internal(
      PendingRequestsController.new,
      name: r'pendingRequestsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingRequestsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingRequestsController = AsyncNotifier<PendingRequests>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
