import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  const Session({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };
}

/// Reads and writes the session as a single record, never as two separate
/// writes. Refresh rotates both tokens together (see RefreshInterceptor);
/// writing them one at a time would let an access-token write succeed while
/// the refresh-token write fails, leaving the app holding a rotated-away
/// refresh token it can never recover with.
abstract class SessionStorage {
  Future<Session?> read();
  Future<void> write(Session session);
  Future<void> clear();
}

class SecureSessionStorage implements SessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'rawwers_session';

  final FlutterSecureStorage _storage;

  @override
  Future<Session?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return null;
    return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> write(Session session) {
    return _storage.write(key: _key, value: jsonEncode(session.toJson()));
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}
