// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_all_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$openAppSettingsHash() => r'd75baedd3b146674a53aa923d5e4c35236744007';

/// Opens this app's page in iOS Settings, where photo access is changed.
/// A provider so a test can see it was asked for without leaving the app.
///
/// Copied from [openAppSettings].
@ProviderFor(openAppSettings)
final openAppSettingsProvider =
    AutoDisposeProvider<Future<bool> Function()>.internal(
      openAppSettings,
      name: r'openAppSettingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$openAppSettingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OpenAppSettingsRef = AutoDisposeProviderRef<Future<bool> Function()>;
String _$saveAllControllerHash() => r'fa21a9b3d9275080bcf7f382cb9786c95715d99b';

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

abstract class _$SaveAllController
    extends BuildlessAutoDisposeNotifier<SaveAllState> {
  late final String galleryId;

  SaveAllState build(String galleryId);
}

/// "Save all" for one delivered gallery.
///
/// Kept alive while a run is going, so leaving the screen does not drop it
/// half way: coming back shows where it is. Once it ends it is released with
/// the screen like everything else.
///
/// Copied from [SaveAllController].
@ProviderFor(SaveAllController)
const saveAllControllerProvider = SaveAllControllerFamily();

/// "Save all" for one delivered gallery.
///
/// Kept alive while a run is going, so leaving the screen does not drop it
/// half way: coming back shows where it is. Once it ends it is released with
/// the screen like everything else.
///
/// Copied from [SaveAllController].
class SaveAllControllerFamily extends Family<SaveAllState> {
  /// "Save all" for one delivered gallery.
  ///
  /// Kept alive while a run is going, so leaving the screen does not drop it
  /// half way: coming back shows where it is. Once it ends it is released with
  /// the screen like everything else.
  ///
  /// Copied from [SaveAllController].
  const SaveAllControllerFamily();

  /// "Save all" for one delivered gallery.
  ///
  /// Kept alive while a run is going, so leaving the screen does not drop it
  /// half way: coming back shows where it is. Once it ends it is released with
  /// the screen like everything else.
  ///
  /// Copied from [SaveAllController].
  SaveAllControllerProvider call(String galleryId) {
    return SaveAllControllerProvider(galleryId);
  }

  @override
  SaveAllControllerProvider getProviderOverride(
    covariant SaveAllControllerProvider provider,
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
  String? get name => r'saveAllControllerProvider';
}

/// "Save all" for one delivered gallery.
///
/// Kept alive while a run is going, so leaving the screen does not drop it
/// half way: coming back shows where it is. Once it ends it is released with
/// the screen like everything else.
///
/// Copied from [SaveAllController].
class SaveAllControllerProvider
    extends AutoDisposeNotifierProviderImpl<SaveAllController, SaveAllState> {
  /// "Save all" for one delivered gallery.
  ///
  /// Kept alive while a run is going, so leaving the screen does not drop it
  /// half way: coming back shows where it is. Once it ends it is released with
  /// the screen like everything else.
  ///
  /// Copied from [SaveAllController].
  SaveAllControllerProvider(String galleryId)
    : this._internal(
        () => SaveAllController()..galleryId = galleryId,
        from: saveAllControllerProvider,
        name: r'saveAllControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$saveAllControllerHash,
        dependencies: SaveAllControllerFamily._dependencies,
        allTransitiveDependencies:
            SaveAllControllerFamily._allTransitiveDependencies,
        galleryId: galleryId,
      );

  SaveAllControllerProvider._internal(
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
  SaveAllState runNotifierBuild(covariant SaveAllController notifier) {
    return notifier.build(galleryId);
  }

  @override
  Override overrideWith(SaveAllController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SaveAllControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<SaveAllController, SaveAllState>
  createElement() {
    return _SaveAllControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveAllControllerProvider && other.galleryId == galleryId;
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
mixin SaveAllControllerRef on AutoDisposeNotifierProviderRef<SaveAllState> {
  /// The parameter `galleryId` of this provider.
  String get galleryId;
}

class _SaveAllControllerProviderElement
    extends AutoDisposeNotifierProviderElement<SaveAllController, SaveAllState>
    with SaveAllControllerRef {
  _SaveAllControllerProviderElement(super.provider);

  @override
  String get galleryId => (origin as SaveAllControllerProvider).galleryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
