// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reviewSubmitControllerHash() =>
    r'3ee7fff0d2d0783cb13064b8bbcb4ee36acbd51a';

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

abstract class _$ReviewSubmitController
    extends BuildlessAutoDisposeNotifier<ReviewSubmitState> {
  late final String bookingId;

  ReviewSubmitState build(String bookingId);
}

/// Sends a client's review of one booking.
///
/// There is no "submitted" state here on purpose. Success refetches the
/// booking, and the booking's own `review` is what turns the prompt into
/// "your review" - so the screen can only ever show a review the server holds.
///
/// Copied from [ReviewSubmitController].
@ProviderFor(ReviewSubmitController)
const reviewSubmitControllerProvider = ReviewSubmitControllerFamily();

/// Sends a client's review of one booking.
///
/// There is no "submitted" state here on purpose. Success refetches the
/// booking, and the booking's own `review` is what turns the prompt into
/// "your review" - so the screen can only ever show a review the server holds.
///
/// Copied from [ReviewSubmitController].
class ReviewSubmitControllerFamily extends Family<ReviewSubmitState> {
  /// Sends a client's review of one booking.
  ///
  /// There is no "submitted" state here on purpose. Success refetches the
  /// booking, and the booking's own `review` is what turns the prompt into
  /// "your review" - so the screen can only ever show a review the server holds.
  ///
  /// Copied from [ReviewSubmitController].
  const ReviewSubmitControllerFamily();

  /// Sends a client's review of one booking.
  ///
  /// There is no "submitted" state here on purpose. Success refetches the
  /// booking, and the booking's own `review` is what turns the prompt into
  /// "your review" - so the screen can only ever show a review the server holds.
  ///
  /// Copied from [ReviewSubmitController].
  ReviewSubmitControllerProvider call(String bookingId) {
    return ReviewSubmitControllerProvider(bookingId);
  }

  @override
  ReviewSubmitControllerProvider getProviderOverride(
    covariant ReviewSubmitControllerProvider provider,
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
  String? get name => r'reviewSubmitControllerProvider';
}

/// Sends a client's review of one booking.
///
/// There is no "submitted" state here on purpose. Success refetches the
/// booking, and the booking's own `review` is what turns the prompt into
/// "your review" - so the screen can only ever show a review the server holds.
///
/// Copied from [ReviewSubmitController].
class ReviewSubmitControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ReviewSubmitController,
          ReviewSubmitState
        > {
  /// Sends a client's review of one booking.
  ///
  /// There is no "submitted" state here on purpose. Success refetches the
  /// booking, and the booking's own `review` is what turns the prompt into
  /// "your review" - so the screen can only ever show a review the server holds.
  ///
  /// Copied from [ReviewSubmitController].
  ReviewSubmitControllerProvider(String bookingId)
    : this._internal(
        () => ReviewSubmitController()..bookingId = bookingId,
        from: reviewSubmitControllerProvider,
        name: r'reviewSubmitControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reviewSubmitControllerHash,
        dependencies: ReviewSubmitControllerFamily._dependencies,
        allTransitiveDependencies:
            ReviewSubmitControllerFamily._allTransitiveDependencies,
        bookingId: bookingId,
      );

  ReviewSubmitControllerProvider._internal(
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
  ReviewSubmitState runNotifierBuild(
    covariant ReviewSubmitController notifier,
  ) {
    return notifier.build(bookingId);
  }

  @override
  Override overrideWith(ReviewSubmitController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReviewSubmitControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<ReviewSubmitController, ReviewSubmitState>
  createElement() {
    return _ReviewSubmitControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewSubmitControllerProvider &&
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
mixin ReviewSubmitControllerRef
    on AutoDisposeNotifierProviderRef<ReviewSubmitState> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _ReviewSubmitControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ReviewSubmitController,
          ReviewSubmitState
        >
    with ReviewSubmitControllerRef {
  _ReviewSubmitControllerProviderElement(super.provider);

  @override
  String get bookingId => (origin as ReviewSubmitControllerProvider).bookingId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
