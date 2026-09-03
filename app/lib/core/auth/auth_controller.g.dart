// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authControllerHash() => r'36acbc157955911eeebe4966dfd87d8e7d80755c';

/// keepAlive, not auto-dispose: this is the session, and it must outlive any
/// particular listener. Under auto-dispose the controller is torn down the
/// moment nothing is watching it - so a momentary gap in listeners (a route
/// transition, a non-widget read) silently re-runs build(), firing a fresh
/// GET /v1/me and dropping any state set by login()/upgradeToPro() in the
/// meantime. The router happens to hold it alive in both apps today, which
/// hid this; that's an accident of wiring, not a guarantee.
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = AsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
