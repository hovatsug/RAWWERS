// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketing_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$marketingAgreementControllerHash() =>
    r'cb88c50f030d24db3e85c2883fb3c7b5740b905f';

/// The marketing clause of the photographer's agreement: an account-level
/// opt-in, off until they turn it on, recorded with the wording shown and
/// when. Turning it off stops new offers and withdraws nothing.
///
/// Copied from [MarketingAgreementController].
@ProviderFor(MarketingAgreementController)
final marketingAgreementControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      MarketingAgreementController,
      ProMarketingAgreementView
    >.internal(
      MarketingAgreementController.new,
      name: r'marketingAgreementControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$marketingAgreementControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MarketingAgreementController =
    AutoDisposeAsyncNotifier<ProMarketingAgreementView>;
String _$bookingMarketingControllerHash() =>
    r'3847cb17801eaf8c22f3d3349f759e2183141013';

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

abstract class _$BookingMarketingController
    extends BuildlessAutoDisposeAsyncNotifier<BookingMarketingSettingsView> {
  late final String gigId;

  FutureOr<BookingMarketingSettingsView> build(String gigId);
}

/// One booking's "Allow marketing use" (the photographer's veto) and
/// "Includes children" (no consent is offered). Both fixed once the client
/// has given permission.
///
/// Copied from [BookingMarketingController].
@ProviderFor(BookingMarketingController)
const bookingMarketingControllerProvider = BookingMarketingControllerFamily();

/// One booking's "Allow marketing use" (the photographer's veto) and
/// "Includes children" (no consent is offered). Both fixed once the client
/// has given permission.
///
/// Copied from [BookingMarketingController].
class BookingMarketingControllerFamily
    extends Family<AsyncValue<BookingMarketingSettingsView>> {
  /// One booking's "Allow marketing use" (the photographer's veto) and
  /// "Includes children" (no consent is offered). Both fixed once the client
  /// has given permission.
  ///
  /// Copied from [BookingMarketingController].
  const BookingMarketingControllerFamily();

  /// One booking's "Allow marketing use" (the photographer's veto) and
  /// "Includes children" (no consent is offered). Both fixed once the client
  /// has given permission.
  ///
  /// Copied from [BookingMarketingController].
  BookingMarketingControllerProvider call(String gigId) {
    return BookingMarketingControllerProvider(gigId);
  }

  @override
  BookingMarketingControllerProvider getProviderOverride(
    covariant BookingMarketingControllerProvider provider,
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
  String? get name => r'bookingMarketingControllerProvider';
}

/// One booking's "Allow marketing use" (the photographer's veto) and
/// "Includes children" (no consent is offered). Both fixed once the client
/// has given permission.
///
/// Copied from [BookingMarketingController].
class BookingMarketingControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          BookingMarketingController,
          BookingMarketingSettingsView
        > {
  /// One booking's "Allow marketing use" (the photographer's veto) and
  /// "Includes children" (no consent is offered). Both fixed once the client
  /// has given permission.
  ///
  /// Copied from [BookingMarketingController].
  BookingMarketingControllerProvider(String gigId)
    : this._internal(
        () => BookingMarketingController()..gigId = gigId,
        from: bookingMarketingControllerProvider,
        name: r'bookingMarketingControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookingMarketingControllerHash,
        dependencies: BookingMarketingControllerFamily._dependencies,
        allTransitiveDependencies:
            BookingMarketingControllerFamily._allTransitiveDependencies,
        gigId: gigId,
      );

  BookingMarketingControllerProvider._internal(
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
  FutureOr<BookingMarketingSettingsView> runNotifierBuild(
    covariant BookingMarketingController notifier,
  ) {
    return notifier.build(gigId);
  }

  @override
  Override overrideWith(BookingMarketingController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookingMarketingControllerProvider._internal(
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
    BookingMarketingController,
    BookingMarketingSettingsView
  >
  createElement() {
    return _BookingMarketingControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingMarketingControllerProvider && other.gigId == gigId;
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
mixin BookingMarketingControllerRef
    on AutoDisposeAsyncNotifierProviderRef<BookingMarketingSettingsView> {
  /// The parameter `gigId` of this provider.
  String get gigId;
}

class _BookingMarketingControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          BookingMarketingController,
          BookingMarketingSettingsView
        >
    with BookingMarketingControllerRef {
  _BookingMarketingControllerProviderElement(super.provider);

  @override
  String get gigId => (origin as BookingMarketingControllerProvider).gigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
