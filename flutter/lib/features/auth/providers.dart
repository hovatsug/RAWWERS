import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api/client.dart';
import '../../data/models/auth_models.dart';
import '../../data/models/session.dart';

class AuthController extends StateNotifier<SessionState> {
  AuthController(this._ref) : super(SessionState.initial()) {
    bootstrap();
  }

  final Ref _ref;

  Future<void> bootstrap() async {
    state = state.copyWith(loading: true, clearError: true);
    final tokenStore = _ref.read(tokenStoreProvider);
    final accessToken = tokenStore.accessToken;
    final refreshToken = await tokenStore.getRefreshToken();

    if ((accessToken == null || accessToken.isEmpty) && (refreshToken == null || refreshToken.isEmpty)) {
      state = state.copyWith(loading: false, clearSession: true);
      return;
    }

    try {
      if (accessToken == null || accessToken.isEmpty) {
        final authRepo = _ref.read(authRepositoryProvider);
        final refreshed = await authRepo.refresh(refreshToken: refreshToken!);
        await tokenStore.setAccessToken(refreshed.accessToken);
        await tokenStore.setRefreshToken(refreshed.refreshToken);
      }
      final token = tokenStore.accessToken;
      if (token == null || token.isEmpty) {
        throw Exception('Missing access token after bootstrap');
      }
      final me = await _ref.read(authRepositoryProvider).me(accessToken: token);
      state = state.copyWith(
        loading: false,
        accessToken: tokenStore.accessToken,
        refreshToken: await tokenStore.getRefreshToken(),
        me: me,
        clearError: true,
      );
    } catch (e) {
      await tokenStore.clear();
      state = state.copyWith(loading: false, clearSession: true, error: e.toString());
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final tokenStore = _ref.read(tokenStoreProvider);
      final token = await authRepo.login(email: email, password: password);
      await tokenStore.setAccessToken(token.accessToken);
      await tokenStore.setRefreshToken(token.refreshToken);
      final me = await authRepo.me(accessToken: token.accessToken);

      state = state.copyWith(
        loading: false,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        me: me,
      );
    } on DioException catch (e) {
      state = state.copyWith(loading: false, error: e.error?.toString() ?? e.message ?? 'Login failed');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _ref.read(authRepositoryProvider).register(email: email, password: password);
      state = state.copyWith(loading: false, clearError: true);
    } on DioException catch (e) {
      state = state.copyWith(loading: false, error: e.error?.toString() ?? e.message ?? 'Registration failed');
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> requestVerifyEmail({required String email}) async {
    await _ref.read(authRepositoryProvider).requestVerifyEmail(email: email);
  }

  Future<void> confirmVerifyEmail({required String code}) async {
    await _ref.read(authRepositoryProvider).confirmVerifyEmail(code: code);
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _ref.read(authRepositoryProvider).requestPasswordReset(email: email);
  }

  Future<void> confirmPasswordReset({required String code, required String newPassword}) async {
    await _ref.read(authRepositoryProvider).confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<void> logout() async {
    final refresh = await _ref.read(tokenStoreProvider).getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _ref.read(authRepositoryProvider).logout(refreshToken: refresh, accessToken: state.accessToken);
      } catch (_) {
        // noop
      }
    }
    await _ref.read(tokenStoreProvider).clear();
    state = state.copyWith(loading: false, clearSession: true, clearError: true);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, SessionState>((ref) {
  return AuthController(ref);
});

final meProvider = Provider<MeResponse?>((ref) => ref.watch(authControllerProvider).me);
