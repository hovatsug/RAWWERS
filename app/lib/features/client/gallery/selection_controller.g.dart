// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selection_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectionControllerHash() =>
    r'188d4dced49715648049723375d03f87dd756f33';

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

abstract class _$SelectionController
    extends BuildlessAutoDisposeAsyncNotifier<SelectionState> {
  late final String galleryId;

  FutureOr<SelectionState> build(String galleryId);
}

/// Choosing photographs, and being told what it costs.
///
/// Tapping is answered locally and immediately - a tick that waits on a round
/// trip feels broken - but every number on screen comes from the server. The
/// two are reconciled by debouncing: taps update the set at once, and a quote
/// is requested once the tapping stops. Until it lands the previous total is
/// shown marked as stale rather than replaced by a local estimate, so the
/// figure never jumps to something invented and then corrects itself.
///
/// Copied from [SelectionController].
@ProviderFor(SelectionController)
const selectionControllerProvider = SelectionControllerFamily();

/// Choosing photographs, and being told what it costs.
///
/// Tapping is answered locally and immediately - a tick that waits on a round
/// trip feels broken - but every number on screen comes from the server. The
/// two are reconciled by debouncing: taps update the set at once, and a quote
/// is requested once the tapping stops. Until it lands the previous total is
/// shown marked as stale rather than replaced by a local estimate, so the
/// figure never jumps to something invented and then corrects itself.
///
/// Copied from [SelectionController].
class SelectionControllerFamily extends Family<AsyncValue<SelectionState>> {
  /// Choosing photographs, and being told what it costs.
  ///
  /// Tapping is answered locally and immediately - a tick that waits on a round
  /// trip feels broken - but every number on screen comes from the server. The
  /// two are reconciled by debouncing: taps update the set at once, and a quote
  /// is requested once the tapping stops. Until it lands the previous total is
  /// shown marked as stale rather than replaced by a local estimate, so the
  /// figure never jumps to something invented and then corrects itself.
  ///
  /// Copied from [SelectionController].
  const SelectionControllerFamily();

  /// Choosing photographs, and being told what it costs.
  ///
  /// Tapping is answered locally and immediately - a tick that waits on a round
  /// trip feels broken - but every number on screen comes from the server. The
  /// two are reconciled by debouncing: taps update the set at once, and a quote
  /// is requested once the tapping stops. Until it lands the previous total is
  /// shown marked as stale rather than replaced by a local estimate, so the
  /// figure never jumps to something invented and then corrects itself.
  ///
  /// Copied from [SelectionController].
  SelectionControllerProvider call(String galleryId) {
    return SelectionControllerProvider(galleryId);
  }

  @override
  SelectionControllerProvider getProviderOverride(
    covariant SelectionControllerProvider provider,
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
  String? get name => r'selectionControllerProvider';
}

/// Choosing photographs, and being told what it costs.
///
/// Tapping is answered locally and immediately - a tick that waits on a round
/// trip feels broken - but every number on screen comes from the server. The
/// two are reconciled by debouncing: taps update the set at once, and a quote
/// is requested once the tapping stops. Until it lands the previous total is
/// shown marked as stale rather than replaced by a local estimate, so the
/// figure never jumps to something invented and then corrects itself.
///
/// Copied from [SelectionController].
class SelectionControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SelectionController,
          SelectionState
        > {
  /// Choosing photographs, and being told what it costs.
  ///
  /// Tapping is answered locally and immediately - a tick that waits on a round
  /// trip feels broken - but every number on screen comes from the server. The
  /// two are reconciled by debouncing: taps update the set at once, and a quote
  /// is requested once the tapping stops. Until it lands the previous total is
  /// shown marked as stale rather than replaced by a local estimate, so the
  /// figure never jumps to something invented and then corrects itself.
  ///
  /// Copied from [SelectionController].
  SelectionControllerProvider(String galleryId)
    : this._internal(
        () => SelectionController()..galleryId = galleryId,
        from: selectionControllerProvider,
        name: r'selectionControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$selectionControllerHash,
        dependencies: SelectionControllerFamily._dependencies,
        allTransitiveDependencies:
            SelectionControllerFamily._allTransitiveDependencies,
        galleryId: galleryId,
      );

  SelectionControllerProvider._internal(
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
  FutureOr<SelectionState> runNotifierBuild(
    covariant SelectionController notifier,
  ) {
    return notifier.build(galleryId);
  }

  @override
  Override overrideWith(SelectionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectionControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<SelectionController, SelectionState>
  createElement() {
    return _SelectionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectionControllerProvider && other.galleryId == galleryId;
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
mixin SelectionControllerRef
    on AutoDisposeAsyncNotifierProviderRef<SelectionState> {
  /// The parameter `galleryId` of this provider.
  String get galleryId;
}

class _SelectionControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SelectionController,
          SelectionState
        >
    with SelectionControllerRef {
  _SelectionControllerProviderElement(super.provider);

  @override
  String get galleryId => (origin as SelectionControllerProvider).galleryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
