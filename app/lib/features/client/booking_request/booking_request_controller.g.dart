// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingRequestControllerHash() =>
    r'a34c07c672425588f131be9052954c120001efe0';

/// Sends a booking request for one package.
///
/// Not a `@riverpod` notifier with state: the form owns its own state and
/// this is a one-shot action. It returns either the new booking's id or a
/// message, so the caller decides what to do with each.
///
/// Copied from [BookingRequestController].
@ProviderFor(BookingRequestController)
final bookingRequestControllerProvider =
    AutoDisposeNotifierProvider<BookingRequestController, void>.internal(
      BookingRequestController.new,
      name: r'bookingRequestControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookingRequestControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookingRequestController = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
