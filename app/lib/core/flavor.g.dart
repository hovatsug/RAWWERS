// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flavor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentFlavorHash() => r'71b329505fea90fa9ab13948788ce9200c6102d7';

/// Which flavor is running. Has no real default — main_client.dart and
/// main_pro.dart each override it via ProviderScope, so anything reading
/// this outside of an override is a wiring bug, not a fallback case.
///
/// Copied from [currentFlavor].
@ProviderFor(currentFlavor)
final currentFlavorProvider = AutoDisposeProvider<AppFlavor>.internal(
  currentFlavor,
  name: r'currentFlavorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentFlavorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentFlavorRef = AutoDisposeProviderRef<AppFlavor>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
