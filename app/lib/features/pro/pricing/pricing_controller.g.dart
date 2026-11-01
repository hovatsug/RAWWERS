// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pricingPreviewHash() => r'111c7adf6d77ced1cc63a434cc4511144fe38799';

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

/// What a client would pay at 10/25/50/100/200 photos, for a price the pro
/// is still typing.
///
/// Keyed on (niche, price, photos included) so the curve recomputes as either
/// number changes: the per-photo price tapers only after the photos the
/// package includes.
/// The public preview endpoint reads existing packages and 404s for a pro
/// pricing something for the first time; this one takes the proposed rate
/// as a parameter and reports the cap rather than enforcing it.
///
/// Copied from [pricingPreview].
@ProviderFor(pricingPreview)
const pricingPreviewProvider = PricingPreviewFamily();

/// What a client would pay at 10/25/50/100/200 photos, for a price the pro
/// is still typing.
///
/// Keyed on (niche, price, photos included) so the curve recomputes as either
/// number changes: the per-photo price tapers only after the photos the
/// package includes.
/// The public preview endpoint reads existing packages and 404s for a pro
/// pricing something for the first time; this one takes the proposed rate
/// as a parameter and reports the cap rather than enforcing it.
///
/// Copied from [pricingPreview].
class PricingPreviewFamily
    extends Family<AsyncValue<ProNichePricingPreviewResponse>> {
  /// What a client would pay at 10/25/50/100/200 photos, for a price the pro
  /// is still typing.
  ///
  /// Keyed on (niche, price, photos included) so the curve recomputes as either
  /// number changes: the per-photo price tapers only after the photos the
  /// package includes.
  /// The public preview endpoint reads existing packages and 404s for a pro
  /// pricing something for the first time; this one takes the proposed rate
  /// as a parameter and reports the cap rather than enforcing it.
  ///
  /// Copied from [pricingPreview].
  const PricingPreviewFamily();

  /// What a client would pay at 10/25/50/100/200 photos, for a price the pro
  /// is still typing.
  ///
  /// Keyed on (niche, price, photos included) so the curve recomputes as either
  /// number changes: the per-photo price tapers only after the photos the
  /// package includes.
  /// The public preview endpoint reads existing packages and 404s for a pro
  /// pricing something for the first time; this one takes the proposed rate
  /// as a parameter and reports the cap rather than enforcing it.
  ///
  /// Copied from [pricingPreview].
  PricingPreviewProvider call({
    required String nicheId,
    required String entryPrice,
    required int includedPhotos,
  }) {
    return PricingPreviewProvider(
      nicheId: nicheId,
      entryPrice: entryPrice,
      includedPhotos: includedPhotos,
    );
  }

  @override
  PricingPreviewProvider getProviderOverride(
    covariant PricingPreviewProvider provider,
  ) {
    return call(
      nicheId: provider.nicheId,
      entryPrice: provider.entryPrice,
      includedPhotos: provider.includedPhotos,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pricingPreviewProvider';
}

/// What a client would pay at 10/25/50/100/200 photos, for a price the pro
/// is still typing.
///
/// Keyed on (niche, price, photos included) so the curve recomputes as either
/// number changes: the per-photo price tapers only after the photos the
/// package includes.
/// The public preview endpoint reads existing packages and 404s for a pro
/// pricing something for the first time; this one takes the proposed rate
/// as a parameter and reports the cap rather than enforcing it.
///
/// Copied from [pricingPreview].
class PricingPreviewProvider
    extends AutoDisposeFutureProvider<ProNichePricingPreviewResponse> {
  /// What a client would pay at 10/25/50/100/200 photos, for a price the pro
  /// is still typing.
  ///
  /// Keyed on (niche, price, photos included) so the curve recomputes as either
  /// number changes: the per-photo price tapers only after the photos the
  /// package includes.
  /// The public preview endpoint reads existing packages and 404s for a pro
  /// pricing something for the first time; this one takes the proposed rate
  /// as a parameter and reports the cap rather than enforcing it.
  ///
  /// Copied from [pricingPreview].
  PricingPreviewProvider({
    required String nicheId,
    required String entryPrice,
    required int includedPhotos,
  }) : this._internal(
         (ref) => pricingPreview(
           ref as PricingPreviewRef,
           nicheId: nicheId,
           entryPrice: entryPrice,
           includedPhotos: includedPhotos,
         ),
         from: pricingPreviewProvider,
         name: r'pricingPreviewProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$pricingPreviewHash,
         dependencies: PricingPreviewFamily._dependencies,
         allTransitiveDependencies:
             PricingPreviewFamily._allTransitiveDependencies,
         nicheId: nicheId,
         entryPrice: entryPrice,
         includedPhotos: includedPhotos,
       );

  PricingPreviewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.nicheId,
    required this.entryPrice,
    required this.includedPhotos,
  }) : super.internal();

  final String nicheId;
  final String entryPrice;
  final int includedPhotos;

  @override
  Override overrideWith(
    FutureOr<ProNichePricingPreviewResponse> Function(
      PricingPreviewRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PricingPreviewProvider._internal(
        (ref) => create(ref as PricingPreviewRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        nicheId: nicheId,
        entryPrice: entryPrice,
        includedPhotos: includedPhotos,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProNichePricingPreviewResponse>
  createElement() {
    return _PricingPreviewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PricingPreviewProvider &&
        other.nicheId == nicheId &&
        other.entryPrice == entryPrice &&
        other.includedPhotos == includedPhotos;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, nicheId.hashCode);
    hash = _SystemHash.combine(hash, entryPrice.hashCode);
    hash = _SystemHash.combine(hash, includedPhotos.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PricingPreviewRef
    on AutoDisposeFutureProviderRef<ProNichePricingPreviewResponse> {
  /// The parameter `nicheId` of this provider.
  String get nicheId;

  /// The parameter `entryPrice` of this provider.
  String get entryPrice;

  /// The parameter `includedPhotos` of this provider.
  int get includedPhotos;
}

class _PricingPreviewProviderElement
    extends AutoDisposeFutureProviderElement<ProNichePricingPreviewResponse>
    with PricingPreviewRef {
  _PricingPreviewProviderElement(super.provider);

  @override
  String get nicheId => (origin as PricingPreviewProvider).nicheId;
  @override
  String get entryPrice => (origin as PricingPreviewProvider).entryPrice;
  @override
  int get includedPhotos => (origin as PricingPreviewProvider).includedPhotos;
}

String _$packagesControllerHash() =>
    r'23a1587d2f690a9a8972cb2ed60ae1bd79d8514e';

/// The pro's own packages, one per niche they price.
///
/// Copied from [PackagesController].
@ProviderFor(PackagesController)
final packagesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PackagesController,
      List<ProPackageView>
    >.internal(
      PackagesController.new,
      name: r'packagesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$packagesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PackagesController = AutoDisposeAsyncNotifier<List<ProPackageView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
