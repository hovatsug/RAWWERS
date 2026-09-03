import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/login_request.dart';
import 'package:rawwers/api/models/register_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/error_mapper.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/api/session.dart';
import 'package:rawwers/core/auth/auth_state.dart';

part 'auth_controller.g.dart';

/// keepAlive, not auto-dispose: this is the session, and it must outlive any
/// particular listener. Under auto-dispose the controller is torn down the
/// moment nothing is watching it - so a momentary gap in listeners (a route
/// transition, a non-widget read) silently re-runs build(), firing a fresh
/// GET /v1/me and dropping any state set by login()/upgradeToPro() in the
/// meantime. The router happens to hold it alive in both apps today, which
/// hid this; that's an accident of wiring, not a guarantee.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthState> build() async {
    final session = await ref.read(sessionStorageProvider).read();
    if (session == null) return const AuthUnauthenticated();
    return _fetchMe();
  }

  Future<AuthState> _fetchMe() async {
    final client = ref.read(authClientProvider);
    final result = await apiCall(() => client.meV1MeGet(authorization: null, xMinusUserMinusId: null));
    return switch (result) {
      Ok(:final value) => AuthAuthenticated(value),
      Err() => const AuthUnauthenticated(),
    };
  }

  /// Returns null on success, an error message otherwise. On success the
  /// controller's own state moves to Authenticated - callers don't need to
  /// react to the return value except to display it.
  Future<String?> login({required String email, required String password}) async {
    final client = ref.read(authClientProvider);
    final result = await apiCall(
      () => client.loginV1AuthLoginPost(requestBody: LoginRequest(email: email, password: password)),
    );
    switch (result) {
      case Ok(:final value):
        await ref
            .read(sessionStorageProvider)
            .write(Session(accessToken: value.accessToken, refreshToken: value.refreshToken));
        state = AsyncData(await _fetchMe());
        return null;
      case Err(:final failure):
        return _messageFor(failure);
    }
  }

  /// POST /v1/auth/register returns a bare success payload, not tokens
  /// (checked against the real endpoint, not assumed) - so this always
  /// follows with a login call using the same credentials. If that specific
  /// follow-up fails, the account still exists: routing back to the
  /// register form would just have the user retry into "email already
  /// exists", so this moves state to Unauthenticated with an explanatory
  /// message instead, and the login screen is where they land.
  ///
  /// Uses a raw dio.post() rather than the generated AuthClient method: the
  /// register endpoint's response is a free-form object with no properties
  /// (`additionalProperties: true`, no `properties` - checked against the
  /// real OpenAPI schema), and swagger_to_dart's generated deserializer for
  /// that specific shape emits invalid Dart (`dynamic.fromJson(...)`,
  /// lib/api/api_client/auth_client.g.dart) - a real generator bug, not
  /// something to hand-patch in generated code. The response body is
  /// discarded either way (this always follows with a real login call), so
  /// bypassing the broken typed wrapper costs nothing here.
  Future<String?> register({required String email, required String password}) async {
    final dio = ref.read(dioProvider);
    try {
      await dio.post<void>('/v1/auth/register', data: RegisterRequest(email: email, password: password).toJson());
    } on DioException catch (e) {
      return _messageFor(mapDioException(e));
    }

    final loginError = await login(email: email, password: password);
    if (loginError != null) {
      state = const AsyncData(AuthUnauthenticated(message: 'Your account was created. Log in to continue.'));
    }
    return null;
  }

  Future<void> logout() async {
    await ref.read(sessionStorageProvider).clear();
    state = const AsyncData(AuthUnauthenticated());
  }

  Future<String?> upgradeToPro() async {
    final client = ref.read(authClientProvider);
    final result = await apiCall(
      () => client.upgradeToProV1MeUpgradeToProPost(authorization: null, xMinusUserMinusId: null),
    );
    switch (result) {
      case Ok():
        state = AsyncData(await _fetchMe());
        return null;
      case Err(:final failure):
        return _messageFor(failure);
    }
  }
}

String _messageFor(ApiFailure failure) {
  if (failure is Validation) {
    for (final messages in failure.fieldErrors.values) {
      if (messages.isNotEmpty) return messages.first;
    }
    return 'Please check your input.';
  }
  return switch (failure) {
    BusinessError(:final message) => message,
    Unauthorized() => 'Incorrect email or password.',
    NetworkError() => 'No connection - check your network and try again.',
    Timeout() => 'That took too long - try again.',
    _ => 'Something went wrong. Please try again.',
  };
}
