// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_lightroom_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lightroomDevicesControllerHash() =>
    r'a5691d33c494953a53fe6aec2779f4c4c59836ba';

/// The devices paired with Lightroom, newest use first, and the most there
/// may be.
///
/// Copied from [LightroomDevicesController].
@ProviderFor(LightroomDevicesController)
final lightroomDevicesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      LightroomDevicesController,
      DeliveryDevicesResponse
    >.internal(
      LightroomDevicesController.new,
      name: r'lightroomDevicesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lightroomDevicesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LightroomDevicesController =
    AutoDisposeAsyncNotifier<DeliveryDevicesResponse>;
String _$pairingCodeControllerHash() =>
    r'3038a03058a9f5a96541d9f0b762d3d946517c08';

/// A one-time pairing code: none yet, or the last one asked for.
///
/// Copied from [PairingCodeController].
@ProviderFor(PairingCodeController)
final pairingCodeControllerProvider =
    AutoDisposeNotifierProvider<
      PairingCodeController,
      AsyncValue<PairingCodeResponse?>
    >.internal(
      PairingCodeController.new,
      name: r'pairingCodeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pairingCodeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PairingCodeController =
    AutoDisposeNotifier<AsyncValue<PairingCodeResponse?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
