// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlockControllerHash() => r'a60fe9b2307e8a6f020147bd22b1c14af1df3554';

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

abstract class _$UnlockController extends BuildlessAutoDisposeNotifier<bool> {
  late final String galleryId;

  bool build(String galleryId);
}

/// The review gate's two ways through, for one delivered gallery: a star
/// rating, or "Report a problem". Either one unlocks the originals on the
/// server; this then reloads the gallery so the photos appear.
///
/// The server decides; nothing here unlocks anything on its own. A refusal
/// is returned as the message to show.
///
/// Copied from [UnlockController].
@ProviderFor(UnlockController)
const unlockControllerProvider = UnlockControllerFamily();

/// The review gate's two ways through, for one delivered gallery: a star
/// rating, or "Report a problem". Either one unlocks the originals on the
/// server; this then reloads the gallery so the photos appear.
///
/// The server decides; nothing here unlocks anything on its own. A refusal
/// is returned as the message to show.
///
/// Copied from [UnlockController].
class UnlockControllerFamily extends Family<bool> {
  /// The review gate's two ways through, for one delivered gallery: a star
  /// rating, or "Report a problem". Either one unlocks the originals on the
  /// server; this then reloads the gallery so the photos appear.
  ///
  /// The server decides; nothing here unlocks anything on its own. A refusal
  /// is returned as the message to show.
  ///
  /// Copied from [UnlockController].
  const UnlockControllerFamily();

  /// The review gate's two ways through, for one delivered gallery: a star
  /// rating, or "Report a problem". Either one unlocks the originals on the
  /// server; this then reloads the gallery so the photos appear.
  ///
  /// The server decides; nothing here unlocks anything on its own. A refusal
  /// is returned as the message to show.
  ///
  /// Copied from [UnlockController].
  UnlockControllerProvider call(String galleryId) {
    return UnlockControllerProvider(galleryId);
  }

  @override
  UnlockControllerProvider getProviderOverride(
    covariant UnlockControllerProvider provider,
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
  String? get name => r'unlockControllerProvider';
}

/// The review gate's two ways through, for one delivered gallery: a star
/// rating, or "Report a problem". Either one unlocks the originals on the
/// server; this then reloads the gallery so the photos appear.
///
/// The server decides; nothing here unlocks anything on its own. A refusal
/// is returned as the message to show.
///
/// Copied from [UnlockController].
class UnlockControllerProvider
    extends AutoDisposeNotifierProviderImpl<UnlockController, bool> {
  /// The review gate's two ways through, for one delivered gallery: a star
  /// rating, or "Report a problem". Either one unlocks the originals on the
  /// server; this then reloads the gallery so the photos appear.
  ///
  /// The server decides; nothing here unlocks anything on its own. A refusal
  /// is returned as the message to show.
  ///
  /// Copied from [UnlockController].
  UnlockControllerProvider(String galleryId)
    : this._internal(
        () => UnlockController()..galleryId = galleryId,
        from: unlockControllerProvider,
        name: r'unlockControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unlockControllerHash,
        dependencies: UnlockControllerFamily._dependencies,
        allTransitiveDependencies:
            UnlockControllerFamily._allTransitiveDependencies,
        galleryId: galleryId,
      );

  UnlockControllerProvider._internal(
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
  bool runNotifierBuild(covariant UnlockController notifier) {
    return notifier.build(galleryId);
  }

  @override
  Override overrideWith(UnlockController Function() create) {
    return ProviderOverride(
      origin: this,
      override: UnlockControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<UnlockController, bool> createElement() {
    return _UnlockControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnlockControllerProvider && other.galleryId == galleryId;
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
mixin UnlockControllerRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `galleryId` of this provider.
  String get galleryId;
}

class _UnlockControllerProviderElement
    extends AutoDisposeNotifierProviderElement<UnlockController, bool>
    with UnlockControllerRef {
  _UnlockControllerProviderElement(super.provider);

  @override
  String get galleryId => (origin as UnlockControllerProvider).galleryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
