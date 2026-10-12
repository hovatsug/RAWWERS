// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_messages_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$proMessagesControllerHash() =>
    r'eeeba35fd279620123e601907ef840134d47bc6a';

/// The photographer's conversations, newest activity first, each with what
/// they have not read. Server-ordered; the app does not re-sort.
///
/// Copied from [ProMessagesController].
@ProviderFor(ProMessagesController)
final proMessagesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ProMessagesController,
      List<ChatThreadSummary>
    >.internal(
      ProMessagesController.new,
      name: r'proMessagesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$proMessagesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProMessagesController =
    AutoDisposeAsyncNotifier<List<ChatThreadSummary>>;
String _$proUnreadControllerHash() =>
    r'c9f727ab48fee6e51c00546515eed2885ad8eeb5';

/// The Messages tab's badge: conversations with something unread.
///
/// Polled every 30 seconds while the app is running - with no push yet, this
/// is how a photographer with the app open learns a client wrote. Kept alive
/// so the badge stays current on every tab, not only on Messages.
///
/// Copied from [ProUnreadController].
@ProviderFor(ProUnreadController)
final proUnreadControllerProvider =
    AsyncNotifierProvider<ProUnreadController, int>.internal(
      ProUnreadController.new,
      name: r'proUnreadControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$proUnreadControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProUnreadController = AsyncNotifier<int>;
String _$proThreadControllerHash() =>
    r'3f0589c523a1423bf8bcb1e9206375aaedce34bf';

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

abstract class _$ProThreadController
    extends BuildlessAutoDisposeAsyncNotifier<ChatThreadDetailResponse> {
  late final String threadId;

  FutureOr<ChatThreadDetailResponse> build(String threadId);
}

/// One conversation, from the photographer's side.
///
/// Copied from [ProThreadController].
@ProviderFor(ProThreadController)
const proThreadControllerProvider = ProThreadControllerFamily();

/// One conversation, from the photographer's side.
///
/// Copied from [ProThreadController].
class ProThreadControllerFamily
    extends Family<AsyncValue<ChatThreadDetailResponse>> {
  /// One conversation, from the photographer's side.
  ///
  /// Copied from [ProThreadController].
  const ProThreadControllerFamily();

  /// One conversation, from the photographer's side.
  ///
  /// Copied from [ProThreadController].
  ProThreadControllerProvider call(String threadId) {
    return ProThreadControllerProvider(threadId);
  }

  @override
  ProThreadControllerProvider getProviderOverride(
    covariant ProThreadControllerProvider provider,
  ) {
    return call(provider.threadId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'proThreadControllerProvider';
}

/// One conversation, from the photographer's side.
///
/// Copied from [ProThreadController].
class ProThreadControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ProThreadController,
          ChatThreadDetailResponse
        > {
  /// One conversation, from the photographer's side.
  ///
  /// Copied from [ProThreadController].
  ProThreadControllerProvider(String threadId)
    : this._internal(
        () => ProThreadController()..threadId = threadId,
        from: proThreadControllerProvider,
        name: r'proThreadControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$proThreadControllerHash,
        dependencies: ProThreadControllerFamily._dependencies,
        allTransitiveDependencies:
            ProThreadControllerFamily._allTransitiveDependencies,
        threadId: threadId,
      );

  ProThreadControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.threadId,
  }) : super.internal();

  final String threadId;

  @override
  FutureOr<ChatThreadDetailResponse> runNotifierBuild(
    covariant ProThreadController notifier,
  ) {
    return notifier.build(threadId);
  }

  @override
  Override overrideWith(ProThreadController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProThreadControllerProvider._internal(
        () => create()..threadId = threadId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        threadId: threadId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ProThreadController,
    ChatThreadDetailResponse
  >
  createElement() {
    return _ProThreadControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProThreadControllerProvider && other.threadId == threadId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, threadId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProThreadControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ChatThreadDetailResponse> {
  /// The parameter `threadId` of this provider.
  String get threadId;
}

class _ProThreadControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ProThreadController,
          ChatThreadDetailResponse
        >
    with ProThreadControllerRef {
  _ProThreadControllerProviderElement(super.provider);

  @override
  String get threadId => (origin as ProThreadControllerProvider).threadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
