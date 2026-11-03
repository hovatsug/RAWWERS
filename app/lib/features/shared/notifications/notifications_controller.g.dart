// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadCountHash() => r'2ce820bcd2695aa29cb1d271978d62e29785a538';

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

/// How many are unread: every kind, or only those whose type starts with
/// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
/// count cannot be had: a badge is not worth an error.
///
/// Copied from [unreadCount].
@ProviderFor(unreadCount)
const unreadCountProvider = UnreadCountFamily();

/// How many are unread: every kind, or only those whose type starts with
/// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
/// count cannot be had: a badge is not worth an error.
///
/// Copied from [unreadCount].
class UnreadCountFamily extends Family<AsyncValue<int>> {
  /// How many are unread: every kind, or only those whose type starts with
  /// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
  /// count cannot be had: a badge is not worth an error.
  ///
  /// Copied from [unreadCount].
  const UnreadCountFamily();

  /// How many are unread: every kind, or only those whose type starts with
  /// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
  /// count cannot be had: a badge is not worth an error.
  ///
  /// Copied from [unreadCount].
  UnreadCountProvider call({String? typePrefix}) {
    return UnreadCountProvider(typePrefix: typePrefix);
  }

  @override
  UnreadCountProvider getProviderOverride(
    covariant UnreadCountProvider provider,
  ) {
    return call(typePrefix: provider.typePrefix);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unreadCountProvider';
}

/// How many are unread: every kind, or only those whose type starts with
/// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
/// count cannot be had: a badge is not worth an error.
///
/// Copied from [unreadCount].
class UnreadCountProvider extends AutoDisposeFutureProvider<int> {
  /// How many are unread: every kind, or only those whose type starts with
  /// [typePrefix] ("shelf.order_" for the dot on My orders). Zero when the
  /// count cannot be had: a badge is not worth an error.
  ///
  /// Copied from [unreadCount].
  UnreadCountProvider({String? typePrefix})
    : this._internal(
        (ref) => unreadCount(ref as UnreadCountRef, typePrefix: typePrefix),
        from: unreadCountProvider,
        name: r'unreadCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$unreadCountHash,
        dependencies: UnreadCountFamily._dependencies,
        allTransitiveDependencies: UnreadCountFamily._allTransitiveDependencies,
        typePrefix: typePrefix,
      );

  UnreadCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.typePrefix,
  }) : super.internal();

  final String? typePrefix;

  @override
  Override overrideWith(
    FutureOr<int> Function(UnreadCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadCountProvider._internal(
        (ref) => create(ref as UnreadCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        typePrefix: typePrefix,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _UnreadCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadCountProvider && other.typePrefix == typePrefix;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, typePrefix.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnreadCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `typePrefix` of this provider.
  String? get typePrefix;
}

class _UnreadCountProviderElement extends AutoDisposeFutureProviderElement<int>
    with UnreadCountRef {
  _UnreadCountProviderElement(super.provider);

  @override
  String? get typePrefix => (origin as UnreadCountProvider).typePrefix;
}

String _$notificationKindReaderHash() =>
    r'552785cf797805a1c4bc964d88297cb9a66991c7';

/// Kept alive: it is called and then awaited by a screen that may be gone
/// by the time the call returns.
///
/// Copied from [notificationKindReader].
@ProviderFor(notificationKindReader)
final notificationKindReaderProvider =
    Provider<NotificationKindReader>.internal(
      notificationKindReader,
      name: r'notificationKindReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationKindReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationKindReaderRef = ProviderRef<NotificationKindReader>;
String _$notificationsControllerHash() =>
    r'52d52ff16b9d09c1c02b589c7c8ba75d7390df28';

/// The signed-in person's notifications, newest first: the most recent 50,
/// read and unread. Both apps read the same feed (GET /v1/me/notifications);
/// each has its own screen and decides where a notification leads.
///
/// Copied from [NotificationsController].
@ProviderFor(NotificationsController)
final notificationsControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationsController,
      List<NotificationView>
    >.internal(
      NotificationsController.new,
      name: r'notificationsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationsController =
    AutoDisposeAsyncNotifier<List<NotificationView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
