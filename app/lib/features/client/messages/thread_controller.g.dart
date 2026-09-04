// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$threadControllerHash() => r'2a56ec7fd7c4929036199c3107d428a10f859270';

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

abstract class _$ThreadController
    extends BuildlessAutoDisposeAsyncNotifier<ChatThreadDetailResponse> {
  late final String threadId;

  FutureOr<ChatThreadDetailResponse> build(String threadId);
}

/// One conversation, with its messages.
///
/// Copied from [ThreadController].
@ProviderFor(ThreadController)
const threadControllerProvider = ThreadControllerFamily();

/// One conversation, with its messages.
///
/// Copied from [ThreadController].
class ThreadControllerFamily
    extends Family<AsyncValue<ChatThreadDetailResponse>> {
  /// One conversation, with its messages.
  ///
  /// Copied from [ThreadController].
  const ThreadControllerFamily();

  /// One conversation, with its messages.
  ///
  /// Copied from [ThreadController].
  ThreadControllerProvider call(String threadId) {
    return ThreadControllerProvider(threadId);
  }

  @override
  ThreadControllerProvider getProviderOverride(
    covariant ThreadControllerProvider provider,
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
  String? get name => r'threadControllerProvider';
}

/// One conversation, with its messages.
///
/// Copied from [ThreadController].
class ThreadControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ThreadController,
          ChatThreadDetailResponse
        > {
  /// One conversation, with its messages.
  ///
  /// Copied from [ThreadController].
  ThreadControllerProvider(String threadId)
    : this._internal(
        () => ThreadController()..threadId = threadId,
        from: threadControllerProvider,
        name: r'threadControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$threadControllerHash,
        dependencies: ThreadControllerFamily._dependencies,
        allTransitiveDependencies:
            ThreadControllerFamily._allTransitiveDependencies,
        threadId: threadId,
      );

  ThreadControllerProvider._internal(
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
    covariant ThreadController notifier,
  ) {
    return notifier.build(threadId);
  }

  @override
  Override overrideWith(ThreadController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ThreadControllerProvider._internal(
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
    ThreadController,
    ChatThreadDetailResponse
  >
  createElement() {
    return _ThreadControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ThreadControllerProvider && other.threadId == threadId;
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
mixin ThreadControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ChatThreadDetailResponse> {
  /// The parameter `threadId` of this provider.
  String get threadId;
}

class _ThreadControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ThreadController,
          ChatThreadDetailResponse
        >
    with ThreadControllerRef {
  _ThreadControllerProviderElement(super.provider);

  @override
  String get threadId => (origin as ThreadControllerProvider).threadId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
