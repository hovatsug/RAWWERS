// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gearControllerHash() => r'9bfc44e382fde47ae759cc792798368fd9e39f6d';

/// The kit a photographer owns.
///
/// Serial numbers are why this exists rather than a free-text "gear" field:
/// they are what an insurer or a police report needs, and nobody types them
/// from memory after the bag is gone.
///
/// Copied from [GearController].
@ProviderFor(GearController)
final gearControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      GearController,
      List<GearItemView>
    >.internal(
      GearController.new,
      name: r'gearControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gearControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GearController = AutoDisposeAsyncNotifier<List<GearItemView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
