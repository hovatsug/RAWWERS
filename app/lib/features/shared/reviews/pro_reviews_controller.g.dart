// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_reviews_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$proReviewsHash() => r'550a39194a966c15399bffe9281a02f178b9ea70';

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

/// A photographer's published reviews, newest first - what a client sees on
/// their profile and what the photographer sees of themselves. One source for
/// both, so a reply the photographer writes is the reply the client reads.
///
/// Copied from [proReviews].
@ProviderFor(proReviews)
const proReviewsProvider = ProReviewsFamily();

/// A photographer's published reviews, newest first - what a client sees on
/// their profile and what the photographer sees of themselves. One source for
/// both, so a reply the photographer writes is the reply the client reads.
///
/// Copied from [proReviews].
class ProReviewsFamily extends Family<AsyncValue<ProReviewsResponse>> {
  /// A photographer's published reviews, newest first - what a client sees on
  /// their profile and what the photographer sees of themselves. One source for
  /// both, so a reply the photographer writes is the reply the client reads.
  ///
  /// Copied from [proReviews].
  const ProReviewsFamily();

  /// A photographer's published reviews, newest first - what a client sees on
  /// their profile and what the photographer sees of themselves. One source for
  /// both, so a reply the photographer writes is the reply the client reads.
  ///
  /// Copied from [proReviews].
  ProReviewsProvider call(String proUserId) {
    return ProReviewsProvider(proUserId);
  }

  @override
  ProReviewsProvider getProviderOverride(
    covariant ProReviewsProvider provider,
  ) {
    return call(provider.proUserId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'proReviewsProvider';
}

/// A photographer's published reviews, newest first - what a client sees on
/// their profile and what the photographer sees of themselves. One source for
/// both, so a reply the photographer writes is the reply the client reads.
///
/// Copied from [proReviews].
class ProReviewsProvider extends AutoDisposeFutureProvider<ProReviewsResponse> {
  /// A photographer's published reviews, newest first - what a client sees on
  /// their profile and what the photographer sees of themselves. One source for
  /// both, so a reply the photographer writes is the reply the client reads.
  ///
  /// Copied from [proReviews].
  ProReviewsProvider(String proUserId)
    : this._internal(
        (ref) => proReviews(ref as ProReviewsRef, proUserId),
        from: proReviewsProvider,
        name: r'proReviewsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$proReviewsHash,
        dependencies: ProReviewsFamily._dependencies,
        allTransitiveDependencies: ProReviewsFamily._allTransitiveDependencies,
        proUserId: proUserId,
      );

  ProReviewsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.proUserId,
  }) : super.internal();

  final String proUserId;

  @override
  Override overrideWith(
    FutureOr<ProReviewsResponse> Function(ProReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProReviewsProvider._internal(
        (ref) => create(ref as ProReviewsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        proUserId: proUserId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProReviewsResponse> createElement() {
    return _ProReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProReviewsProvider && other.proUserId == proUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, proUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProReviewsRef on AutoDisposeFutureProviderRef<ProReviewsResponse> {
  /// The parameter `proUserId` of this provider.
  String get proUserId;
}

class _ProReviewsProviderElement
    extends AutoDisposeFutureProviderElement<ProReviewsResponse>
    with ProReviewsRef {
  _ProReviewsProviderElement(super.provider);

  @override
  String get proUserId => (origin as ProReviewsProvider).proUserId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
