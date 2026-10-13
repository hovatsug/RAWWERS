// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_now_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableNowControllerHash() =>
    r'df8397f49384b3f9135fab8e686668343b3d7a64';

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
