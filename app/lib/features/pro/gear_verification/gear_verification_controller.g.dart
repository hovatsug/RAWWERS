// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_verification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gearVerificationControllerHash() =>
    r'd96e9e0d7c4ee9e29c77cd8ecc9ae92e5000fe96';

/// What the photographer's gear looks like right now, from the server.
///
/// No local notion of "verified": the floor is computed there from real rows,
/// so a photographer who removes their lens sees the requirement reopen.
///
/// Copied from [GearVerificationController].
@ProviderFor(GearVerificationController)
final gearVerificationControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      GearVerificationController,
      GearVerificationListResponse
    >.internal(
      GearVerificationController.new,
      name: r'gearVerificationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gearVerificationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GearVerificationController =
    AutoDisposeAsyncNotifier<GearVerificationListResponse>;
String _$gearSubmitControllerHash() =>
    r'145b6e9bd3e692e6253132a4b60b282d5d730803';

/// Sending one camera file: choose it, upload it, have it read.
///
/// One file proves both the body and the lens it was shot on, so there is no
/// "add a body" and "add a lens" - which would have made a photographer prove
/// the same camera again for every lens.
///
/// Copied from [GearSubmitController].
@ProviderFor(GearSubmitController)
final gearSubmitControllerProvider =
    AutoDisposeNotifierProvider<GearSubmitController, GearSubmitState>.internal(
      GearSubmitController.new,
      name: r'gearSubmitControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gearSubmitControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GearSubmitController = AutoDisposeNotifier<GearSubmitState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
