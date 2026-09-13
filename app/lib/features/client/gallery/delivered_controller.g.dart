// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivered_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveredControllerHash() =>
    r'953f2128ca87abd0ef9ceb528e2fc40b35020d4c';

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

abstract class _$DeliveredController
    extends BuildlessAutoDisposeAsyncNotifier<DeliveredState> {
  late final String galleryId;

  FutureOr<DeliveredState> build(String galleryId);
}

/// The photographs a client owns.
///
/// Built by crossing the gallery listing with the downloads endpoint: the
/// listing supplies order and thumbnails, the downloads call supplies both
/// the set of assets this client actually owns and the links to the originals.
/// Neither alone is enough - the listing does not know what was bought, and
/// the downloads response does not know the order they were shot in.
///
/// Copied from [DeliveredController].
@ProviderFor(DeliveredController)
const deliveredControllerProvider = DeliveredControllerFamily();

/// The photographs a client owns.
///
/// Built by crossing the gallery listing with the downloads endpoint: the
/// listing supplies order and thumbnails, the downloads call supplies both
/// the set of assets this client actually owns and the links to the originals.
/// Neither alone is enough - the listing does not know what was bought, and
/// the downloads response does not know the order they were shot in.
///
/// Copied from [DeliveredController].
class DeliveredControllerFamily extends Family<AsyncValue<DeliveredState>> {
  /// The photographs a client owns.
  ///
  /// Built by crossing the gallery listing with the downloads endpoint: the
  /// listing supplies order and thumbnails, the downloads call supplies both
  /// the set of assets this client actually owns and the links to the originals.
  /// Neither alone is enough - the listing does not know what was bought, and
  /// the downloads response does not know the order they were shot in.
  ///
  /// Copied from [DeliveredController].
  const DeliveredControllerFamily();

  /// The photographs a client owns.
  ///
  /// Built by crossing the gallery listing with the downloads endpoint: the
  /// listing supplies order and thumbnails, the downloads call supplies both
  /// the set of assets this client actually owns and the links to the originals.
  /// Neither alone is enough - the listing does not know what was bought, and
  /// the downloads response does not know the order they were shot in.
  ///
  /// Copied from [DeliveredController].
  DeliveredControllerProvider call(String galleryId) {
    return DeliveredControllerProvider(galleryId);
  }

  @override
  DeliveredControllerProvider getProviderOverride(
    covariant DeliveredControllerProvider provider,
  ) {
    return call(provider.galleryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveredControllerProvider';
}

/// The photographs a client owns.
///
/// Built by crossing the gallery listing with the downloads endpoint: the
/// listing supplies order and thumbnails, the downloads call supplies both
/// the set of assets this client actually owns and the links to the originals.
/// Neither alone is enough - the listing does not know what was bought, and
/// the downloads response does not know the order they were shot in.
///
/// Copied from [DeliveredController].
class DeliveredControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DeliveredController,
          DeliveredState
        > {
  /// The photographs a client owns.
  ///
  /// Built by crossing the gallery listing with the downloads endpoint: the
  /// listing supplies order and thumbnails, the downloads call supplies both
  /// the set of assets this client actually owns and the links to the originals.
  /// Neither alone is enough - the listing does not know what was bought, and
  /// the downloads response does not know the order they were shot in.
  ///
  /// Copied from [DeliveredController].
  DeliveredControllerProvider(String galleryId)
    : this._internal(
        () => DeliveredController()..galleryId = galleryId,
        from: deliveredControllerProvider,
        name: r'deliveredControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveredControllerHash,
        dependencies: DeliveredControllerFamily._dependencies,
        allTransitiveDependencies:
            DeliveredControllerFamily._allTransitiveDependencies,
        galleryId: galleryId,
      );

  DeliveredControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.galleryId,
  }) : super.internal();

  final String galleryId;

  @override
  FutureOr<DeliveredState> runNotifierBuild(
    covariant DeliveredController notifier,
  ) {
    return notifier.build(galleryId);
  }

  @override
  Override overrideWith(DeliveredController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeliveredControllerProvider._internal(
        () => create()..galleryId = galleryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        galleryId: galleryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DeliveredController, DeliveredState>
  createElement() {
    return _DeliveredControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveredControllerProvider && other.galleryId == galleryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, galleryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveredControllerRef
    on AutoDisposeAsyncNotifierProviderRef<DeliveredState> {
  /// The parameter `galleryId` of this provider.
  String get galleryId;
}

class _DeliveredControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DeliveredController,
          DeliveredState
        >
    with DeliveredControllerRef {
  _DeliveredControllerProviderElement(super.provider);

  @override
  String get galleryId => (origin as DeliveredControllerProvider).galleryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
