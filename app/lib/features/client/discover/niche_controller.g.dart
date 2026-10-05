// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'niche_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nicheControllerHash() => r'2a4ab1bf32c80b384ab3bfeb41f6fe221b3c3202';

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

abstract class _$NicheController
    extends BuildlessAutoDisposeAsyncNotifier<NicheState> {
  late final String nicheSlug;

  FutureOr<NicheState> build(String nicheSlug);
}

/// One niche's page: the home screen's rows, narrowed by the server.
///
/// The same request as the home screen with one more parameter, and the same
/// division of labour - which rows exist, who is in them, what they are called
/// and whether an empty one is sent at all are all decided server-side. This
/// controller asks and reports; it holds no opinion about fairness.
///
/// Copied from [NicheController].
@ProviderFor(NicheController)
const nicheControllerProvider = NicheControllerFamily();

/// One niche's page: the home screen's rows, narrowed by the server.
///
/// The same request as the home screen with one more parameter, and the same
/// division of labour - which rows exist, who is in them, what they are called
/// and whether an empty one is sent at all are all decided server-side. This
/// controller asks and reports; it holds no opinion about fairness.
///
/// Copied from [NicheController].
class NicheControllerFamily extends Family<AsyncValue<NicheState>> {
  /// One niche's page: the home screen's rows, narrowed by the server.
  ///
  /// The same request as the home screen with one more parameter, and the same
  /// division of labour - which rows exist, who is in them, what they are called
  /// and whether an empty one is sent at all are all decided server-side. This
  /// controller asks and reports; it holds no opinion about fairness.
  ///
  /// Copied from [NicheController].
  const NicheControllerFamily();

  /// One niche's page: the home screen's rows, narrowed by the server.
  ///
  /// The same request as the home screen with one more parameter, and the same
  /// division of labour - which rows exist, who is in them, what they are called
  /// and whether an empty one is sent at all are all decided server-side. This
  /// controller asks and reports; it holds no opinion about fairness.
  ///
  /// Copied from [NicheController].
  NicheControllerProvider call(String nicheSlug) {
    return NicheControllerProvider(nicheSlug);
  }

  @override
  NicheControllerProvider getProviderOverride(
    covariant NicheControllerProvider provider,
  ) {
    return call(provider.nicheSlug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'nicheControllerProvider';
}

/// One niche's page: the home screen's rows, narrowed by the server.
///
/// The same request as the home screen with one more parameter, and the same
/// division of labour - which rows exist, who is in them, what they are called
/// and whether an empty one is sent at all are all decided server-side. This
/// controller asks and reports; it holds no opinion about fairness.
///
/// Copied from [NicheController].
class NicheControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<NicheController, NicheState> {
  /// One niche's page: the home screen's rows, narrowed by the server.
  ///
  /// The same request as the home screen with one more parameter, and the same
  /// division of labour - which rows exist, who is in them, what they are called
  /// and whether an empty one is sent at all are all decided server-side. This
  /// controller asks and reports; it holds no opinion about fairness.
  ///
  /// Copied from [NicheController].
  NicheControllerProvider(String nicheSlug)
    : this._internal(
        () => NicheController()..nicheSlug = nicheSlug,
        from: nicheControllerProvider,
        name: r'nicheControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$nicheControllerHash,
        dependencies: NicheControllerFamily._dependencies,
        allTransitiveDependencies:
            NicheControllerFamily._allTransitiveDependencies,
        nicheSlug: nicheSlug,
      );

  NicheControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.nicheSlug,
  }) : super.internal();

  final String nicheSlug;

  @override
  FutureOr<NicheState> runNotifierBuild(covariant NicheController notifier) {
    return notifier.build(nicheSlug);
  }

  @override
  Override overrideWith(NicheController Function() create) {
    return ProviderOverride(
      origin: this,
      override: NicheControllerProvider._internal(
        () => create()..nicheSlug = nicheSlug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        nicheSlug: nicheSlug,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<NicheController, NicheState>
  createElement() {
    return _NicheControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NicheControllerProvider && other.nicheSlug == nicheSlug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, nicheSlug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NicheControllerRef on AutoDisposeAsyncNotifierProviderRef<NicheState> {
  /// The parameter `nicheSlug` of this provider.
  String get nicheSlug;
}

class _NicheControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<NicheController, NicheState>
    with NicheControllerRef {
  _NicheControllerProviderElement(super.provider);

  @override
  String get nicheSlug => (origin as NicheControllerProvider).nicheSlug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
