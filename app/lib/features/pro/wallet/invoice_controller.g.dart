// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$invoiceHash() => r'c8e5f0832834e5cb4d95004d0c360c646c2b7349';

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

/// One gig's invoice.
///
/// Fetched rather than assembled from the ledger row that opened it: the
/// ledger carries gross, fee and net, and every other line - the split inside
/// the fee, the client's credit, the photo count - exists only on the server.
/// Reconstructing them here would be the app doing arithmetic the server
/// already did, which is how two answers to one question appear.
///
/// Copied from [invoice].
@ProviderFor(invoice)
const invoiceProvider = InvoiceFamily();

/// One gig's invoice.
///
/// Fetched rather than assembled from the ledger row that opened it: the
/// ledger carries gross, fee and net, and every other line - the split inside
/// the fee, the client's credit, the photo count - exists only on the server.
/// Reconstructing them here would be the app doing arithmetic the server
/// already did, which is how two answers to one question appear.
///
/// Copied from [invoice].
class InvoiceFamily extends Family<AsyncValue<GigInvoiceView>> {
  /// One gig's invoice.
  ///
  /// Fetched rather than assembled from the ledger row that opened it: the
  /// ledger carries gross, fee and net, and every other line - the split inside
  /// the fee, the client's credit, the photo count - exists only on the server.
  /// Reconstructing them here would be the app doing arithmetic the server
  /// already did, which is how two answers to one question appear.
  ///
  /// Copied from [invoice].
  const InvoiceFamily();

  /// One gig's invoice.
  ///
  /// Fetched rather than assembled from the ledger row that opened it: the
  /// ledger carries gross, fee and net, and every other line - the split inside
  /// the fee, the client's credit, the photo count - exists only on the server.
  /// Reconstructing them here would be the app doing arithmetic the server
  /// already did, which is how two answers to one question appear.
  ///
  /// Copied from [invoice].
  InvoiceProvider call({required String gigId}) {
    return InvoiceProvider(gigId: gigId);
  }

  @override
  InvoiceProvider getProviderOverride(covariant InvoiceProvider provider) {
    return call(gigId: provider.gigId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'invoiceProvider';
}

/// One gig's invoice.
///
/// Fetched rather than assembled from the ledger row that opened it: the
/// ledger carries gross, fee and net, and every other line - the split inside
/// the fee, the client's credit, the photo count - exists only on the server.
/// Reconstructing them here would be the app doing arithmetic the server
/// already did, which is how two answers to one question appear.
///
/// Copied from [invoice].
class InvoiceProvider extends AutoDisposeFutureProvider<GigInvoiceView> {
  /// One gig's invoice.
  ///
  /// Fetched rather than assembled from the ledger row that opened it: the
  /// ledger carries gross, fee and net, and every other line - the split inside
  /// the fee, the client's credit, the photo count - exists only on the server.
  /// Reconstructing them here would be the app doing arithmetic the server
  /// already did, which is how two answers to one question appear.
  ///
  /// Copied from [invoice].
  InvoiceProvider({required String gigId})
    : this._internal(
        (ref) => invoice(ref as InvoiceRef, gigId: gigId),
        from: invoiceProvider,
        name: r'invoiceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$invoiceHash,
        dependencies: InvoiceFamily._dependencies,
        allTransitiveDependencies: InvoiceFamily._allTransitiveDependencies,
        gigId: gigId,
      );

  InvoiceProvider._internal(
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
  Override overrideWith(
    FutureOr<GigInvoiceView> Function(InvoiceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoiceProvider._internal(
        (ref) => create(ref as InvoiceRef),
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
  AutoDisposeFutureProviderElement<GigInvoiceView> createElement() {
    return _InvoiceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoiceProvider && other.gigId == gigId;
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
mixin InvoiceRef on AutoDisposeFutureProviderRef<GigInvoiceView> {
  /// The parameter `gigId` of this provider.
  String get gigId;
}

class _InvoiceProviderElement
    extends AutoDisposeFutureProviderElement<GigInvoiceView>
    with InvoiceRef {
  _InvoiceProviderElement(super.provider);

  @override
  String get gigId => (origin as InvoiceProvider).gigId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
