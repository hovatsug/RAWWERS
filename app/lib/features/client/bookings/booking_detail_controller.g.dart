// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingDetailHash() => r'f42bfad30d8dd10ff7ee04773e91899aa365ba18';

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

/// One booking, with its transition history.
///
/// Copied from [bookingDetail].
@ProviderFor(bookingDetail)
const bookingDetailProvider = BookingDetailFamily();

/// One booking, with its transition history.
///
/// Copied from [bookingDetail].
class BookingDetailFamily
    extends Family<AsyncValue<ClientBookingStatusResponse>> {
  /// One booking, with its transition history.
  ///
  /// Copied from [bookingDetail].
  const BookingDetailFamily();

  /// One booking, with its transition history.
  ///
  /// Copied from [bookingDetail].
  BookingDetailProvider call(String bookingId) {
    return BookingDetailProvider(bookingId);
  }

  @override
  BookingDetailProvider getProviderOverride(
    covariant BookingDetailProvider provider,
  ) {
    return call(provider.bookingId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookingDetailProvider';
}

/// One booking, with its transition history.
///
/// Copied from [bookingDetail].
class BookingDetailProvider
    extends AutoDisposeFutureProvider<ClientBookingStatusResponse> {
  /// One booking, with its transition history.
  ///
  /// Copied from [bookingDetail].
  BookingDetailProvider(String bookingId)
    : this._internal(
        (ref) => bookingDetail(ref as BookingDetailRef, bookingId),
        from: bookingDetailProvider,
        name: r'bookingDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookingDetailHash,
        dependencies: BookingDetailFamily._dependencies,
        allTransitiveDependencies:
            BookingDetailFamily._allTransitiveDependencies,
        bookingId: bookingId,
      );

  BookingDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  Override overrideWith(
    FutureOr<ClientBookingStatusResponse> Function(BookingDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingDetailProvider._internal(
        (ref) => create(ref as BookingDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ClientBookingStatusResponse>
  createElement() {
    return _BookingDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailProvider && other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookingDetailRef
    on AutoDisposeFutureProviderRef<ClientBookingStatusResponse> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingDetailProviderElement
    extends AutoDisposeFutureProviderElement<ClientBookingStatusResponse>
    with BookingDetailRef {
  _BookingDetailProviderElement(super.provider);

  @override
  String get bookingId => (origin as BookingDetailProvider).bookingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
