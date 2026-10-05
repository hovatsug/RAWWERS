// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availabilityTodayHash() => r'db6bbb2083c17c19cbeeca7221a05e269b7e92e8';

/// Today as the server counts it: a UTC date. A device a few hours behind UTC
/// would otherwise ask about "today" after the server's today has ended, and
/// be refused for asking about the past.
///
/// A provider so a test can fix the date: what "past" and "beyond the
/// horizon" mean depends on it, and a test that only works mid-month is a
/// test that quietly skips its checks on the 1st.
///
/// Copied from [availabilityToday].
@ProviderFor(availabilityToday)
final availabilityTodayProvider = AutoDisposeProvider<DateTime>.internal(
  availabilityToday,
  name: r'availabilityTodayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$availabilityTodayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailabilityTodayRef = AutoDisposeProviderRef<DateTime>;
String _$proAvailabilityHash() => r'250e45d55f7d3a48405e2a7391c71765f913f4df';

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

/// One month of a photographer's calendar for one package, clamped to what
/// can be booked at all: from today, up to the horizon. Null for a month
/// entirely outside that.
///
/// Which days are open and when a shoot can start are the server's answer -
/// the rule every booking path enforces - so this asks and does not compute.
///
/// Copied from [proAvailability].
@ProviderFor(proAvailability)
const proAvailabilityProvider = ProAvailabilityFamily();

/// One month of a photographer's calendar for one package, clamped to what
/// can be booked at all: from today, up to the horizon. Null for a month
/// entirely outside that.
///
/// Which days are open and when a shoot can start are the server's answer -
/// the rule every booking path enforces - so this asks and does not compute.
///
/// Copied from [proAvailability].
class ProAvailabilityFamily
    extends Family<AsyncValue<ClientAvailabilityResponse?>> {
  /// One month of a photographer's calendar for one package, clamped to what
  /// can be booked at all: from today, up to the horizon. Null for a month
  /// entirely outside that.
  ///
  /// Which days are open and when a shoot can start are the server's answer -
  /// the rule every booking path enforces - so this asks and does not compute.
  ///
  /// Copied from [proAvailability].
  const ProAvailabilityFamily();

  /// One month of a photographer's calendar for one package, clamped to what
  /// can be booked at all: from today, up to the horizon. Null for a month
  /// entirely outside that.
  ///
  /// Which days are open and when a shoot can start are the server's answer -
  /// the rule every booking path enforces - so this asks and does not compute.
  ///
  /// Copied from [proAvailability].
  ProAvailabilityProvider call(
    String proUserId,
    String packageId,
    DateTime month,
  ) {
    return ProAvailabilityProvider(proUserId, packageId, month);
  }

  @override
  ProAvailabilityProvider getProviderOverride(
    covariant ProAvailabilityProvider provider,
  ) {
    return call(provider.proUserId, provider.packageId, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'proAvailabilityProvider';
}

/// One month of a photographer's calendar for one package, clamped to what
/// can be booked at all: from today, up to the horizon. Null for a month
/// entirely outside that.
///
/// Which days are open and when a shoot can start are the server's answer -
/// the rule every booking path enforces - so this asks and does not compute.
///
/// Copied from [proAvailability].
class ProAvailabilityProvider
    extends AutoDisposeFutureProvider<ClientAvailabilityResponse?> {
  /// One month of a photographer's calendar for one package, clamped to what
  /// can be booked at all: from today, up to the horizon. Null for a month
  /// entirely outside that.
  ///
  /// Which days are open and when a shoot can start are the server's answer -
  /// the rule every booking path enforces - so this asks and does not compute.
  ///
  /// Copied from [proAvailability].
  ProAvailabilityProvider(String proUserId, String packageId, DateTime month)
    : this._internal(
        (ref) => proAvailability(
          ref as ProAvailabilityRef,
          proUserId,
          packageId,
          month,
        ),
        from: proAvailabilityProvider,
        name: r'proAvailabilityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$proAvailabilityHash,
        dependencies: ProAvailabilityFamily._dependencies,
        allTransitiveDependencies:
            ProAvailabilityFamily._allTransitiveDependencies,
        proUserId: proUserId,
        packageId: packageId,
        month: month,
      );

  ProAvailabilityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.proUserId,
    required this.packageId,
    required this.month,
  }) : super.internal();

  final String proUserId;
  final String packageId;
  final DateTime month;

  @override
  Override overrideWith(
    FutureOr<ClientAvailabilityResponse?> Function(ProAvailabilityRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProAvailabilityProvider._internal(
        (ref) => create(ref as ProAvailabilityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        proUserId: proUserId,
        packageId: packageId,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ClientAvailabilityResponse?>
  createElement() {
    return _ProAvailabilityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProAvailabilityProvider &&
        other.proUserId == proUserId &&
        other.packageId == packageId &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, proUserId.hashCode);
    hash = _SystemHash.combine(hash, packageId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProAvailabilityRef
    on AutoDisposeFutureProviderRef<ClientAvailabilityResponse?> {
  /// The parameter `proUserId` of this provider.
  String get proUserId;

  /// The parameter `packageId` of this provider.
  String get packageId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _ProAvailabilityProviderElement
    extends AutoDisposeFutureProviderElement<ClientAvailabilityResponse?>
    with ProAvailabilityRef {
  _ProAvailabilityProviderElement(super.provider);

  @override
  String get proUserId => (origin as ProAvailabilityProvider).proUserId;
  @override
  String get packageId => (origin as ProAvailabilityProvider).packageId;
  @override
  DateTime get month => (origin as ProAvailabilityProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
