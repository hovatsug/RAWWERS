// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'findings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$findingsControllerHash() =>
    r'e9d4ba98e27d465b3a2f928c494b02edf70c78ae';

/// The photographer's own findings, strike count and any booking pause.
/// Only theirs: the server never returns anyone else's, and nothing here is
/// shown to clients.
///
/// Copied from [FindingsController].
@ProviderFor(FindingsController)
final findingsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      FindingsController,
      MyFindingsResponse
    >.internal(
      FindingsController.new,
      name: r'findingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$findingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FindingsController = AutoDisposeAsyncNotifier<MyFindingsResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
