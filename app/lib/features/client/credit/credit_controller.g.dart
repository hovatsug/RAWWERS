// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myCreditHash() => r'73cc7384e96248b37a1a36761b9fb5ffb470f9ff';

/// The client's credit, in euros, with its history newest first.
///
/// Copied from [myCredit].
@ProviderFor(myCredit)
final myCreditProvider = AutoDisposeFutureProvider<MyCreditResponse>.internal(
  myCredit,
  name: r'myCreditProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myCreditHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyCreditRef = AutoDisposeFutureProviderRef<MyCreditResponse>;
String _$bookingCreditHash() => r'3c060a9b6c348d011749e07b6c67655e250a6457';

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

/// What credit would take off this booking's payment. Null when it cannot
/// be had: the switch is simply not shown.
///
/// Copied from [bookingCredit].
@ProviderFor(bookingCredit)
const bookingCreditProvider = BookingCreditFamily();

/// What credit would take off this booking's payment. Null when it cannot
/// be had: the switch is simply not shown.
///
/// Copied from [bookingCredit].
class BookingCreditFamily extends Family<AsyncValue<BookingCreditPreview?>> {
  /// What credit would take off this booking's payment. Null when it cannot
  /// be had: the switch is simply not shown.
  ///
  /// Copied from [bookingCredit].
  const BookingCreditFamily();

  /// What credit would take off this booking's payment. Null when it cannot
  /// be had: the switch is simply not shown.
  ///
  /// Copied from [bookingCredit].
  BookingCreditProvider call(String bookingId) {
    return BookingCreditProvider(bookingId);
  }

  @override
  BookingCreditProvider getProviderOverride(
    covariant BookingCreditProvider provider,
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
  String? get name => r'bookingCreditProvider';
}

/// What credit would take off this booking's payment. Null when it cannot
/// be had: the switch is simply not shown.
///
/// Copied from [bookingCredit].
class BookingCreditProvider
    extends AutoDisposeFutureProvider<BookingCreditPreview?> {
  /// What credit would take off this booking's payment. Null when it cannot
  /// be had: the switch is simply not shown.
  ///
  /// Copied from [bookingCredit].
  BookingCreditProvider(String bookingId)
    : this._internal(
        (ref) => bookingCredit(ref as BookingCreditRef, bookingId),
        from: bookingCreditProvider,
        name: r'bookingCreditProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookingCreditHash,
        dependencies: BookingCreditFamily._dependencies,
        allTransitiveDependencies:
            BookingCreditFamily._allTransitiveDependencies,
        bookingId: bookingId,
      );

  BookingCreditProvider._internal(
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
    FutureOr<BookingCreditPreview?> Function(BookingCreditRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BookingCreditProvider._internal(
        (ref) => create(ref as BookingCreditRef),
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
  AutoDisposeFutureProviderElement<BookingCreditPreview?> createElement() {
    return _BookingCreditProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingCreditProvider && other.bookingId == bookingId;
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
mixin BookingCreditRef on AutoDisposeFutureProviderRef<BookingCreditPreview?> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingCreditProviderElement
    extends AutoDisposeFutureProviderElement<BookingCreditPreview?>
    with BookingCreditRef {
  _BookingCreditProviderElement(super.provider);

  @override
  String get bookingId => (origin as BookingCreditProvider).bookingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
