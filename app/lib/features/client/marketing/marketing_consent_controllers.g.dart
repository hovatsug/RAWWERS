// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_consent_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketingOfferControllerHash() =>
    r'2263e762aff7399b062d73850957ac8dda6876e0';

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

abstract class _$MarketingOfferController
    extends BuildlessAutoDisposeAsyncNotifier<MarketingConsentOfferResponse> {
  late final String gigId;

  FutureOr<MarketingConsentOfferResponse> build(String gigId);
}

/// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
/// server says whether to offer it, the wording, the terms and the photos.
///
/// Copied from [MarketingOfferController].
@ProviderFor(MarketingOfferController)
const marketingOfferControllerProvider = MarketingOfferControllerFamily();

/// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
/// server says whether to offer it, the wording, the terms and the photos.
///
/// Copied from [MarketingOfferController].
class MarketingOfferControllerFamily
    extends Family<AsyncValue<MarketingConsentOfferResponse>> {
  /// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
  /// server says whether to offer it, the wording, the terms and the photos.
  ///
  /// Copied from [MarketingOfferController].
  const MarketingOfferControllerFamily();

  /// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
  /// server says whether to offer it, the wording, the terms and the photos.
  ///
  /// Copied from [MarketingOfferController].
  MarketingOfferControllerProvider call(String gigId) {
    return MarketingOfferControllerProvider(gigId);
  }

  @override
  MarketingOfferControllerProvider getProviderOverride(
    covariant MarketingOfferControllerProvider provider,
  ) {
    return call(provider.gigId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketingOfferControllerProvider';
}

/// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
/// server says whether to offer it, the wording, the terms and the photos.
///
/// Copied from [MarketingOfferController].
class MarketingOfferControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MarketingOfferController,
          MarketingConsentOfferResponse
        > {
  /// "Let RAWWERS feature your photos? Earn RAW credit." for one booking: the
  /// server says whether to offer it, the wording, the terms and the photos.
  ///
  /// Copied from [MarketingOfferController].
  MarketingOfferControllerProvider(String gigId)
    : this._internal(
        () => MarketingOfferController()..gigId = gigId,
        from: marketingOfferControllerProvider,
        name: r'marketingOfferControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$marketingOfferControllerHash,
        dependencies: MarketingOfferControllerFamily._dependencies,
        allTransitiveDependencies:
            MarketingOfferControllerFamily._allTransitiveDependencies,
        gigId: gigId,
      );

  MarketingOfferControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gigId,
  }) : super.internal();

  final String gigId;

  @override
  FutureOr<MarketingConsentOfferResponse> runNotifierBuild(
    covariant MarketingOfferController notifier,
  ) {
    return notifier.build(gigId);
  }

  @override
  Override overrideWith(MarketingOfferController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MarketingOfferControllerProvider._internal(
        () => create()..gigId = gigId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gigId: gigId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MarketingOfferController,
    MarketingConsentOfferResponse
  >
  createElement() {
    return _MarketingOfferControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketingOfferControllerProvider && other.gigId == gigId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gigId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketingOfferControllerRef
    on AutoDisposeAsyncNotifierProviderRef<MarketingConsentOfferResponse> {
  /// The parameter `gigId` of this provider.
  String get gigId;
}

class _MarketingOfferControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MarketingOfferController,
          MarketingConsentOfferResponse
        >
    with MarketingOfferControllerRef {
  _MarketingOfferControllerProviderElement(super.provider);

  @override
  String get gigId => (origin as MarketingOfferControllerProvider).gigId;
}

String _$myMarketingConsentsControllerHash() =>
    r'36c25600370e988cf7a9a486ddf55bcabb4d1838';

/// Settings > Marketing permissions: every photo the client has given, with
/// its end date; withdraw one or all, renew one ending soon.
///
/// Copied from [MyMarketingConsentsController].
@ProviderFor(MyMarketingConsentsController)
final myMarketingConsentsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      MyMarketingConsentsController,
      List<MarketingConsentView>
    >.internal(
      MyMarketingConsentsController.new,
      name: r'myMarketingConsentsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myMarketingConsentsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyMarketingConsentsController =
    AutoDisposeAsyncNotifier<List<MarketingConsentView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
