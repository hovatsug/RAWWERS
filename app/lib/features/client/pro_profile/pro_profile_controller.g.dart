// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$proProfileHash() => r'5d37a507c99a6593c60e1bd9fea798cca021046f';

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

/// One photographer's public profile.
///
/// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
/// parameters and gates on them: the city rollout check runs before the
/// profile is loaded at all, so a profile is not reachable outside a city
/// we operate in. That means the browse location is a precondition here in
/// exactly the way it is for Discover, and a cleared location surfaces as
/// [LocationNotSet] rather than as a 403 the user cannot act on.
///
/// Copied from [proProfile].
@ProviderFor(proProfile)
const proProfileProvider = ProProfileFamily();

/// One photographer's public profile.
///
/// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
/// parameters and gates on them: the city rollout check runs before the
/// profile is loaded at all, so a profile is not reachable outside a city
/// we operate in. That means the browse location is a precondition here in
/// exactly the way it is for Discover, and a cleared location surfaces as
/// [LocationNotSet] rather than as a 403 the user cannot act on.
///
/// Copied from [proProfile].
class ProProfileFamily extends Family<AsyncValue<ClientProProfileResponse>> {
  /// One photographer's public profile.
  ///
  /// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
  /// parameters and gates on them: the city rollout check runs before the
  /// profile is loaded at all, so a profile is not reachable outside a city
  /// we operate in. That means the browse location is a precondition here in
  /// exactly the way it is for Discover, and a cleared location surfaces as
  /// [LocationNotSet] rather than as a 403 the user cannot act on.
  ///
  /// Copied from [proProfile].
  const ProProfileFamily();

  /// One photographer's public profile.
  ///
  /// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
  /// parameters and gates on them: the city rollout check runs before the
  /// profile is loaded at all, so a profile is not reachable outside a city
  /// we operate in. That means the browse location is a precondition here in
  /// exactly the way it is for Discover, and a cleared location surfaces as
  /// [LocationNotSet] rather than as a 403 the user cannot act on.
  ///
  /// Copied from [proProfile].
  ProProfileProvider call(String proUserId) {
    return ProProfileProvider(proUserId);
  }

  @override
  ProProfileProvider getProviderOverride(
    covariant ProProfileProvider provider,
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
  String? get name => r'proProfileProvider';
}

/// One photographer's public profile.
///
/// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
/// parameters and gates on them: the city rollout check runs before the
/// profile is loaded at all, so a profile is not reachable outside a city
/// we operate in. That means the browse location is a precondition here in
/// exactly the way it is for Discover, and a cleared location surfaces as
/// [LocationNotSet] rather than as a 403 the user cannot act on.
///
/// Copied from [proProfile].
class ProProfileProvider
    extends AutoDisposeFutureProvider<ClientProProfileResponse> {
  /// One photographer's public profile.
  ///
  /// `GET /v1/client/pros/{id}` takes `country` and `city` as required query
  /// parameters and gates on them: the city rollout check runs before the
  /// profile is loaded at all, so a profile is not reachable outside a city
  /// we operate in. That means the browse location is a precondition here in
  /// exactly the way it is for Discover, and a cleared location surfaces as
  /// [LocationNotSet] rather than as a 403 the user cannot act on.
  ///
  /// Copied from [proProfile].
  ProProfileProvider(String proUserId)
    : this._internal(
        (ref) => proProfile(ref as ProProfileRef, proUserId),
        from: proProfileProvider,
        name: r'proProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$proProfileHash,
        dependencies: ProProfileFamily._dependencies,
        allTransitiveDependencies: ProProfileFamily._allTransitiveDependencies,
        proUserId: proUserId,
      );

  ProProfileProvider._internal(
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
    FutureOr<ClientProProfileResponse> Function(ProProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProProfileProvider._internal(
        (ref) => create(ref as ProProfileRef),
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
  AutoDisposeFutureProviderElement<ClientProProfileResponse> createElement() {
    return _ProProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProProfileProvider && other.proUserId == proUserId;
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
mixin ProProfileRef on AutoDisposeFutureProviderRef<ClientProProfileResponse> {
  /// The parameter `proUserId` of this provider.
  String get proUserId;
}

class _ProProfileProviderElement
    extends AutoDisposeFutureProviderElement<ClientProProfileResponse>
    with ProProfileRef {
  _ProProfileProviderElement(super.provider);

  @override
  String get proUserId => (origin as ProProfileProvider).proUserId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
