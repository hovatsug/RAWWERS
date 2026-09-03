// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionStorageHash() => r'cdda297699f32e9b70a06b624aed9af4196dd3cc';

/// See also [sessionStorage].
@ProviderFor(sessionStorage)
final sessionStorageProvider = Provider<SessionStorage>.internal(
  sessionStorage,
  name: r'sessionStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionStorageRef = ProviderRef<SessionStorage>;
String _$dioHash() => r'26b296adf3ce8fb20efe34204641620a0684a7aa';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = Provider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = ProviderRef<Dio>;
String _$authClientHash() => r'188286271f09a4e01c0c0e3e4efac17c8263d305';

/// See also [authClient].
@ProviderFor(authClient)
final authClientProvider = AutoDisposeProvider<AuthClient>.internal(
  authClient,
  name: r'authClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthClientRef = AutoDisposeProviderRef<AuthClient>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
