import 'package:dio/dio.dart';

import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<TokenResponse> login({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/login', data: {'email': email, 'password': password});
    return TokenResponse.fromJson(response.data ?? {});
  }

  Future<void> register({required String email, required String password}) async {
    await _dio.post('/auth/register', data: {'email': email, 'password': password});
  }

  Future<void> requestVerifyEmail({required String email}) async {
    await _dio.post('/auth/verify-email/request', data: {'email': email});
  }

  Future<void> confirmVerifyEmail({required String code}) async {
    await _dio.post('/auth/verify-email/confirm', data: {'code': code});
  }

  Future<void> requestPasswordReset({required String email}) async {
    await _dio.post('/auth/password-reset/request', data: {'email': email});
  }

  Future<void> confirmPasswordReset({required String code, required String newPassword}) async {
    await _dio.post('/auth/password-reset/confirm', data: {'code': code, 'new_password': newPassword});
  }

  Future<TokenResponse> refresh({required String refreshToken}) async {
    final response = await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refresh_token': refreshToken});
    return TokenResponse.fromJson(response.data ?? {});
  }

  Future<void> logout({required String refreshToken, String? accessToken}) async {
    await _dio.post(
      '/auth/logout',
      data: {'refresh_token': refreshToken, 'revoke_family': true},
      options: Options(
        headers: accessToken == null ? const <String, dynamic>{} : <String, dynamic>{'Authorization': 'Bearer $accessToken'},
      ),
    );
  }

  Future<MeResponse> me({required String accessToken}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me',
      options: Options(headers: <String, dynamic>{'Authorization': 'Bearer $accessToken'}),
    );
    return MeResponse.fromJson(response.data ?? {});
  }
}
