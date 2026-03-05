import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore(this._secureStorage);

  static const _refreshKey = 'rawwers_refresh_token';
  final FlutterSecureStorage _secureStorage;

  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
  }

  Future<void> setRefreshToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _secureStorage.delete(key: _refreshKey);
      return;
    }
    await _secureStorage.write(key: _refreshKey, value: token);
  }

  Future<String?> getRefreshToken() => _secureStorage.read(key: _refreshKey);

  Future<void> clear() async {
    _accessToken = null;
    await _secureStorage.delete(key: _refreshKey);
  }
}
