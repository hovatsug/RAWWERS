// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_now_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableNowControllerHash() =>
    r'ee1b6341ac977ed11f141abe0d0580a7f9067b7b';

/// The photographer's "Available now": switched on or not, until when, and
/// whether clients can book at short notice right now - all the server's
/// answer, never worked out on the phone.
///
/// Copied from [AvailableNowController].
@ProviderFor(AvailableNowController)
final availableNowControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      AvailableNowController,
      AvailableNowView
    >.internal(
      AvailableNowController.new,
      name: r'availableNowControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$availableNowControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AvailableNowController = AutoDisposeAsyncNotifier<AvailableNowView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
