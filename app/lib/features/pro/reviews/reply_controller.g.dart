// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$replyControllerHash() => r'ce1cd5da29937b082c83ffd1db01c652710e4bbd';

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

abstract class _$ReplyController
    extends BuildlessAutoDisposeNotifier<ReplyState> {
  late final String reviewId;

  ReplyState build(String reviewId);
}

/// A photographer's one reply to one review.
///
/// Like the client's review, nothing here records that a reply was posted.
/// Success refetches the photographer's reviews, and the reply appears
/// because the list now carries it.
///
/// Copied from [ReplyController].
@ProviderFor(ReplyController)
const replyControllerProvider = ReplyControllerFamily();

/// A photographer's one reply to one review.
///
/// Like the client's review, nothing here records that a reply was posted.
/// Success refetches the photographer's reviews, and the reply appears
/// because the list now carries it.
///
/// Copied from [ReplyController].
class ReplyControllerFamily extends Family<ReplyState> {
  /// A photographer's one reply to one review.
  ///
  /// Like the client's review, nothing here records that a reply was posted.
  /// Success refetches the photographer's reviews, and the reply appears
  /// because the list now carries it.
  ///
  /// Copied from [ReplyController].
  const ReplyControllerFamily();

  /// A photographer's one reply to one review.
  ///
  /// Like the client's review, nothing here records that a reply was posted.
  /// Success refetches the photographer's reviews, and the reply appears
  /// because the list now carries it.
  ///
  /// Copied from [ReplyController].
  ReplyControllerProvider call(String reviewId) {
    return ReplyControllerProvider(reviewId);
  }

  @override
  ReplyControllerProvider getProviderOverride(
    covariant ReplyControllerProvider provider,
  ) {
    return call(provider.reviewId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'replyControllerProvider';
}

/// A photographer's one reply to one review.
///
/// Like the client's review, nothing here records that a reply was posted.
/// Success refetches the photographer's reviews, and the reply appears
/// because the list now carries it.
///
/// Copied from [ReplyController].
class ReplyControllerProvider
    extends AutoDisposeNotifierProviderImpl<ReplyController, ReplyState> {
  /// A photographer's one reply to one review.
  ///
  /// Like the client's review, nothing here records that a reply was posted.
  /// Success refetches the photographer's reviews, and the reply appears
  /// because the list now carries it.
  ///
  /// Copied from [ReplyController].
  ReplyControllerProvider(String reviewId)
    : this._internal(
        () => ReplyController()..reviewId = reviewId,
        from: replyControllerProvider,
        name: r'replyControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$replyControllerHash,
        dependencies: ReplyControllerFamily._dependencies,
        allTransitiveDependencies:
            ReplyControllerFamily._allTransitiveDependencies,
        reviewId: reviewId,
      );

  ReplyControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reviewId,
  }) : super.internal();

  final String reviewId;

  @override
  ReplyState runNotifierBuild(covariant ReplyController notifier) {
    return notifier.build(reviewId);
  }

  @override
  Override overrideWith(ReplyController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ReplyControllerProvider._internal(
        () => create()..reviewId = reviewId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reviewId: reviewId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ReplyController, ReplyState>
  createElement() {
    return _ReplyControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReplyControllerProvider && other.reviewId == reviewId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reviewId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReplyControllerRef on AutoDisposeNotifierProviderRef<ReplyState> {
  /// The parameter `reviewId` of this provider.
  String get reviewId;
}

class _ReplyControllerProviderElement
    extends AutoDisposeNotifierProviderElement<ReplyController, ReplyState>
    with ReplyControllerRef {
  _ReplyControllerProviderElement(super.provider);

  @override
  String get reviewId => (origin as ReplyControllerProvider).reviewId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
