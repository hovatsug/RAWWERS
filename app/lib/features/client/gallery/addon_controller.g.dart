// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addon_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addonControllerHash() => r'371e3dda77993929be975f0f8bfa7ccc36fca7bb';

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

abstract class _$AddonController
    extends BuildlessAutoDisposeAsyncNotifier<AddonState> {
  late final String galleryId;

  FutureOr<AddonState> build(String galleryId);
}

/// See also [AddonController].
@ProviderFor(AddonController)
const addonControllerProvider = AddonControllerFamily();

/// See also [AddonController].
class AddonControllerFamily extends Family<AsyncValue<AddonState>> {
  /// See also [AddonController].
  const AddonControllerFamily();

  /// See also [AddonController].
  AddonControllerProvider call(String galleryId) {
    return AddonControllerProvider(galleryId);
  }

  @override
  AddonControllerProvider getProviderOverride(
    covariant AddonControllerProvider provider,
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
  String? get name => r'addonControllerProvider';
}

/// See also [AddonController].
class AddonControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AddonController, AddonState> {
  /// See also [AddonController].
  AddonControllerProvider(String galleryId)
    : this._internal(
        () => AddonController()..galleryId = galleryId,
        from: addonControllerProvider,
        name: r'addonControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$addonControllerHash,
        dependencies: AddonControllerFamily._dependencies,
        allTransitiveDependencies:
            AddonControllerFamily._allTransitiveDependencies,
        galleryId: galleryId,
      );

  AddonControllerProvider._internal(
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
  FutureOr<AddonState> runNotifierBuild(covariant AddonController notifier) {
    return notifier.build(galleryId);
  }

  @override
  Override overrideWith(AddonController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AddonControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AddonController, AddonState>
  createElement() {
    return _AddonControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AddonControllerProvider && other.galleryId == galleryId;
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
mixin AddonControllerRef on AutoDisposeAsyncNotifierProviderRef<AddonState> {
  /// The parameter `galleryId` of this provider.
  String get galleryId;
}

class _AddonControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AddonController, AddonState>
    with AddonControllerRef {
  _AddonControllerProviderElement(super.provider);

  @override
  String get galleryId => (origin as AddonControllerProvider).galleryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
