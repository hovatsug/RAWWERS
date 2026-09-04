// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingsControllerHash() =>
    r'd67d4717cd5b923eb6dfcbcea3ec1b0b4c5a71f2';

/// The client's own bookings, newest first.
///
/// Unfiltered on purpose, unlike the pro's Requests tab. A photographer opens
/// their queue to answer "what needs me" and so defaults to pending; a client
/// opens this to answer "where are my shoots up to", and a booking they are
/// waiting on, one they need to pay for, and one that was delivered last week
/// all belong in that answer. `?status=` exists on the endpoint if a filter is
/// wanted later.
///
/// Copied from [BookingsController].
@ProviderFor(BookingsController)
final bookingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BookingsController,
      CursorPage<ClientBookingListItem>
    >.internal(
      BookingsController.new,
      name: r'bookingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookingsController =
    AutoDisposeAsyncNotifier<CursorPage<ClientBookingListItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
