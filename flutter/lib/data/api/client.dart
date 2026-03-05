import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config.dart';
import '../repositories/auth_repository.dart';
import 'interceptors.dart';
import 'token_store.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore(ref.watch(secureStorageProvider));
});

final unauthenticatedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: '${AppConfig.apiBaseUrl}/v1'));
  dio.interceptors.add(SafeLogInterceptor());
  dio.interceptors.add(ErrorMappingInterceptor());
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(unauthenticatedDioProvider));
});

final apiDioProvider = Provider<Dio>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final dio = Dio(BaseOptions(baseUrl: '${AppConfig.apiBaseUrl}/v1'));
  final retryClient = Dio(BaseOptions(baseUrl: '${AppConfig.apiBaseUrl}/v1'));
  retryClient.interceptors.add(ErrorMappingInterceptor());

  dio.interceptors.add(
    AuthInterceptor(
      tokenStore: tokenStore,
      onRefresh: () async {
        final refreshToken = await tokenStore.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await tokenStore.clear();
          return null;
        }
        try {
          final token = await authRepository.refresh(refreshToken: refreshToken);
          await tokenStore.setAccessToken(token.accessToken);
          await tokenStore.setRefreshToken(token.refreshToken);
          return token;
        } catch (_) {
          await tokenStore.clear();
          return null;
        }
      },
      retryClient: retryClient,
    ),
  );

  dio.interceptors.add(SafeLogInterceptor());
  dio.interceptors.add(ErrorMappingInterceptor());
  return dio;
});
