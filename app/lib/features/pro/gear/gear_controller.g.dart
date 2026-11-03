// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gear_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cameraSearchHash() => r'6b274b61c94c21d2514d83f1fbc31a83e5c1313c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// The camera catalogue, searched by name or model code, for linking a body
/// in My gear: what The Shelf matches batteries and chargers against.
///
/// Copied from [cameraSearch].
@ProviderFor(cameraSearch)
const cameraSearchProvider = CameraSearchFamily();

/// The camera catalogue, searched by name or model code, for linking a body
/// in My gear: what The Shelf matches batteries and chargers against.
///
/// Copied from [cameraSearch].
class CameraSearchFamily
    extends Family<AsyncValue<List<ShelfCameraModelView>>> {
  /// The camera catalogue, searched by name or model code, for linking a body
  /// in My gear: what The Shelf matches batteries and chargers against.
  ///
  /// Copied from [cameraSearch].
  const CameraSearchFamily();

  /// The camera catalogue, searched by name or model code, for linking a body
  /// in My gear: what The Shelf matches batteries and chargers against.
  ///
  /// Copied from [cameraSearch].
  CameraSearchProvider call(String query) {
    return CameraSearchProvider(query);
  }

  @override
  CameraSearchProvider getProviderOverride(
    covariant CameraSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cameraSearchProvider';
}

/// The camera catalogue, searched by name or model code, for linking a body
/// in My gear: what The Shelf matches batteries and chargers against.
///
/// Copied from [cameraSearch].
class CameraSearchProvider
    extends AutoDisposeFutureProvider<List<ShelfCameraModelView>> {
  /// The camera catalogue, searched by name or model code, for linking a body
  /// in My gear: what The Shelf matches batteries and chargers against.
  ///
  /// Copied from [cameraSearch].
  CameraSearchProvider(String query)
    : this._internal(
        (ref) => cameraSearch(ref as CameraSearchRef, query),
        from: cameraSearchProvider,
        name: r'cameraSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cameraSearchHash,
        dependencies: CameraSearchFamily._dependencies,
        allTransitiveDependencies:
            CameraSearchFamily._allTransitiveDependencies,
        query: query,
      );

  CameraSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ShelfCameraModelView>> Function(CameraSearchRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CameraSearchProvider._internal(
        (ref) => create(ref as CameraSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ShelfCameraModelView>> createElement() {
    return _CameraSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CameraSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CameraSearchRef
    on AutoDisposeFutureProviderRef<List<ShelfCameraModelView>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _CameraSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<ShelfCameraModelView>>
    with CameraSearchRef {
  _CameraSearchProviderElement(super.provider);

  @override
  String get query => (origin as CameraSearchProvider).query;
}

String _$gearControllerHash() => r'ca2e2715a9a0dfed41f8a1e5d865d438bf70b43f';

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
