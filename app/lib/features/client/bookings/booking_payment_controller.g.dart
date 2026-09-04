// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_payment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingPaymentControllerHash() =>
    r'd70c2a2d7b6895ebf8d7fcc5f87b0268fb08d650';

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

abstract class _$BookingPaymentController
    extends BuildlessAutoDisposeNotifier<PaymentProgress> {
  late final String bookingId;

  PaymentProgress build(String bookingId);
}

/// See also [BookingPaymentController].
@ProviderFor(BookingPaymentController)
const bookingPaymentControllerProvider = BookingPaymentControllerFamily();

/// See also [BookingPaymentController].
class BookingPaymentControllerFamily extends Family<PaymentProgress> {
  /// See also [BookingPaymentController].
  const BookingPaymentControllerFamily();

  /// See also [BookingPaymentController].
  BookingPaymentControllerProvider call(String bookingId) {
    return BookingPaymentControllerProvider(bookingId);
  }

  @override
  BookingPaymentControllerProvider getProviderOverride(
    covariant BookingPaymentControllerProvider provider,
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
  String? get name => r'bookingPaymentControllerProvider';
}

/// See also [BookingPaymentController].
class BookingPaymentControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          BookingPaymentController,
          PaymentProgress
        > {
  /// See also [BookingPaymentController].
  BookingPaymentControllerProvider(String bookingId)
    : this._internal(
        () => BookingPaymentController()..bookingId = bookingId,
        from: bookingPaymentControllerProvider,
        name: r'bookingPaymentControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookingPaymentControllerHash,
        dependencies: BookingPaymentControllerFamily._dependencies,
        allTransitiveDependencies:
            BookingPaymentControllerFamily._allTransitiveDependencies,
        bookingId: bookingId,
      );

  BookingPaymentControllerProvider._internal(
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
  PaymentProgress runNotifierBuild(
    covariant BookingPaymentController notifier,
  ) {
    return notifier.build(bookingId);
  }

  @override
  Override overrideWith(BookingPaymentController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookingPaymentControllerProvider._internal(
        () => create()..bookingId = bookingId,
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
  AutoDisposeNotifierProviderElement<BookingPaymentController, PaymentProgress>
  createElement() {
    return _BookingPaymentControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingPaymentControllerProvider &&
        other.bookingId == bookingId;
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
mixin BookingPaymentControllerRef
    on AutoDisposeNotifierProviderRef<PaymentProgress> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingPaymentControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          BookingPaymentController,
          PaymentProgress
        >
    with BookingPaymentControllerRef {
  _BookingPaymentControllerProviderElement(super.provider);

  @override
  String get bookingId =>
      (origin as BookingPaymentControllerProvider).bookingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
