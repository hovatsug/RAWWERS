import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/api_client/auth_client.dart';
import 'package:rawwers/core/api/dio_client.dart';
import 'package:rawwers/core/api/session.dart';
import 'package:rawwers/core/env.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) => SecureSessionStorage();

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return createDio(baseUrl: Env.apiBaseUrl, sessionStorage: ref.watch(sessionStorageProvider));
}

@riverpod
AuthClient authClient(Ref ref) => AuthClient(ref.watch(dioProvider));
