// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_gallery_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveryGalleryControllerHash() =>
    r'a5dfc8968178ad33572057f5d547ac9e89682a37';

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

abstract class _$DeliveryGalleryController
    extends BuildlessAutoDisposeAsyncNotifier<GalleryDetailResponse> {
  late final GigResponse gig;

  FutureOr<GalleryDetailResponse> build(GigResponse gig);
}

/// The gallery of proofs for one gig.
///
/// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
/// screen is safe to repeat - but the first call is the one that fixes
/// included_photos and extra_photo_price, and later calls silently ignore
/// the body. Those two numbers therefore come from the gig's pricing
/// snapshot, which is what the client already agreed to pay, rather than
/// from anything typed here.
///
/// Copied from [DeliveryGalleryController].
@ProviderFor(DeliveryGalleryController)
const deliveryGalleryControllerProvider = DeliveryGalleryControllerFamily();

/// The gallery of proofs for one gig.
///
/// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
/// screen is safe to repeat - but the first call is the one that fixes
/// included_photos and extra_photo_price, and later calls silently ignore
/// the body. Those two numbers therefore come from the gig's pricing
/// snapshot, which is what the client already agreed to pay, rather than
/// from anything typed here.
///
/// Copied from [DeliveryGalleryController].
class DeliveryGalleryControllerFamily
    extends Family<AsyncValue<GalleryDetailResponse>> {
  /// The gallery of proofs for one gig.
  ///
  /// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
  /// screen is safe to repeat - but the first call is the one that fixes
  /// included_photos and extra_photo_price, and later calls silently ignore
  /// the body. Those two numbers therefore come from the gig's pricing
  /// snapshot, which is what the client already agreed to pay, rather than
  /// from anything typed here.
  ///
  /// Copied from [DeliveryGalleryController].
  const DeliveryGalleryControllerFamily();

  /// The gallery of proofs for one gig.
  ///
  /// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
  /// screen is safe to repeat - but the first call is the one that fixes
  /// included_photos and extra_photo_price, and later calls silently ignore
  /// the body. Those two numbers therefore come from the gig's pricing
  /// snapshot, which is what the client already agreed to pay, rather than
  /// from anything typed here.
  ///
  /// Copied from [DeliveryGalleryController].
  DeliveryGalleryControllerProvider call(GigResponse gig) {
    return DeliveryGalleryControllerProvider(gig);
  }

  @override
  DeliveryGalleryControllerProvider getProviderOverride(
    covariant DeliveryGalleryControllerProvider provider,
  ) {
    return call(provider.gig);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryGalleryControllerProvider';
}

/// The gallery of proofs for one gig.
///
/// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
/// screen is safe to repeat - but the first call is the one that fixes
/// included_photos and extra_photo_price, and later calls silently ignore
/// the body. Those two numbers therefore come from the gig's pricing
/// snapshot, which is what the client already agreed to pay, rather than
/// from anything typed here.
///
/// Copied from [DeliveryGalleryController].
class DeliveryGalleryControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DeliveryGalleryController,
          GalleryDetailResponse
        > {
  /// The gallery of proofs for one gig.
  ///
  /// POST /v1/gigs/{id}/proof-gallery is get-or-create, so opening this
  /// screen is safe to repeat - but the first call is the one that fixes
  /// included_photos and extra_photo_price, and later calls silently ignore
  /// the body. Those two numbers therefore come from the gig's pricing
  /// snapshot, which is what the client already agreed to pay, rather than
  /// from anything typed here.
  ///
  /// Copied from [DeliveryGalleryController].
  DeliveryGalleryControllerProvider(GigResponse gig)
    : this._internal(
        () => DeliveryGalleryController()..gig = gig,
        from: deliveryGalleryControllerProvider,
        name: r'deliveryGalleryControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryGalleryControllerHash,
        dependencies: DeliveryGalleryControllerFamily._dependencies,
        allTransitiveDependencies:
            DeliveryGalleryControllerFamily._allTransitiveDependencies,
        gig: gig,
      );

  DeliveryGalleryControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gig,
  }) : super.internal();

  final GigResponse gig;

  @override
  FutureOr<GalleryDetailResponse> runNotifierBuild(
    covariant DeliveryGalleryController notifier,
  ) {
    return notifier.build(gig);
  }

  @override
  Override overrideWith(DeliveryGalleryController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeliveryGalleryControllerProvider._internal(
        () => create()..gig = gig,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gig: gig,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    DeliveryGalleryController,
    GalleryDetailResponse
  >
  createElement() {
    return _DeliveryGalleryControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryGalleryControllerProvider && other.gig == gig;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gig.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryGalleryControllerRef
    on AutoDisposeAsyncNotifierProviderRef<GalleryDetailResponse> {
  /// The parameter `gig` of this provider.
  GigResponse get gig;
}

class _DeliveryGalleryControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DeliveryGalleryController,
          GalleryDetailResponse
        >
    with DeliveryGalleryControllerRef {
  _DeliveryGalleryControllerProviderElement(super.provider);

  @override
  GigResponse get gig => (origin as DeliveryGalleryControllerProvider).gig;
}

String _$deliveryUploadControllerHash() =>
    r'd00627906e41a55b9f5a3960923bfa16f08bb3a6';

abstract class _$DeliveryUploadController
    extends BuildlessAutoDisposeNotifier<Map<String, UploadProgress>> {
  late final GigResponse gig;

  Map<String, UploadProgress> build(GigResponse gig);
}

/// Uploads proofs into one gig's gallery.
///
/// Separate from the portfolio uploader because the purpose and visibility
/// differ: these are `proof` assets for one client, not public portfolio
/// work, and getting that backwards would publish a client's shoot.
///
/// Copied from [DeliveryUploadController].
@ProviderFor(DeliveryUploadController)
const deliveryUploadControllerProvider = DeliveryUploadControllerFamily();

/// Uploads proofs into one gig's gallery.
///
/// Separate from the portfolio uploader because the purpose and visibility
/// differ: these are `proof` assets for one client, not public portfolio
/// work, and getting that backwards would publish a client's shoot.
///
/// Copied from [DeliveryUploadController].
class DeliveryUploadControllerFamily
    extends Family<Map<String, UploadProgress>> {
  /// Uploads proofs into one gig's gallery.
  ///
  /// Separate from the portfolio uploader because the purpose and visibility
  /// differ: these are `proof` assets for one client, not public portfolio
  /// work, and getting that backwards would publish a client's shoot.
  ///
  /// Copied from [DeliveryUploadController].
  const DeliveryUploadControllerFamily();

  /// Uploads proofs into one gig's gallery.
  ///
  /// Separate from the portfolio uploader because the purpose and visibility
  /// differ: these are `proof` assets for one client, not public portfolio
  /// work, and getting that backwards would publish a client's shoot.
  ///
  /// Copied from [DeliveryUploadController].
  DeliveryUploadControllerProvider call(GigResponse gig) {
    return DeliveryUploadControllerProvider(gig);
  }

  @override
  DeliveryUploadControllerProvider getProviderOverride(
    covariant DeliveryUploadControllerProvider provider,
  ) {
    return call(provider.gig);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryUploadControllerProvider';
}

/// Uploads proofs into one gig's gallery.
///
/// Separate from the portfolio uploader because the purpose and visibility
/// differ: these are `proof` assets for one client, not public portfolio
/// work, and getting that backwards would publish a client's shoot.
///
/// Copied from [DeliveryUploadController].
class DeliveryUploadControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          DeliveryUploadController,
          Map<String, UploadProgress>
        > {
  /// Uploads proofs into one gig's gallery.
  ///
  /// Separate from the portfolio uploader because the purpose and visibility
  /// differ: these are `proof` assets for one client, not public portfolio
  /// work, and getting that backwards would publish a client's shoot.
  ///
  /// Copied from [DeliveryUploadController].
  DeliveryUploadControllerProvider(GigResponse gig)
    : this._internal(
        () => DeliveryUploadController()..gig = gig,
        from: deliveryUploadControllerProvider,
        name: r'deliveryUploadControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryUploadControllerHash,
        dependencies: DeliveryUploadControllerFamily._dependencies,
        allTransitiveDependencies:
            DeliveryUploadControllerFamily._allTransitiveDependencies,
        gig: gig,
      );

  DeliveryUploadControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gig,
  }) : super.internal();

  final GigResponse gig;

  @override
  Map<String, UploadProgress> runNotifierBuild(
    covariant DeliveryUploadController notifier,
  ) {
    return notifier.build(gig);
  }

  @override
  Override overrideWith(DeliveryUploadController Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeliveryUploadControllerProvider._internal(
        () => create()..gig = gig,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gig: gig,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    DeliveryUploadController,
    Map<String, UploadProgress>
  >
  createElement() {
    return _DeliveryUploadControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryUploadControllerProvider && other.gig == gig;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gig.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryUploadControllerRef
    on AutoDisposeNotifierProviderRef<Map<String, UploadProgress>> {
  /// The parameter `gig` of this provider.
  GigResponse get gig;
}

class _DeliveryUploadControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          DeliveryUploadController,
          Map<String, UploadProgress>
        >
    with DeliveryUploadControllerRef {
  _DeliveryUploadControllerProviderElement(super.provider);

  @override
  GigResponse get gig => (origin as DeliveryUploadControllerProvider).gig;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
