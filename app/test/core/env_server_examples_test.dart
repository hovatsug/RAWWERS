// The committed example files for running the apps against the test server
// (env/*.server.example.json). They are copied to env/*.server.json, which
// git ignores; the examples themselves must stay placeholders, because the
// repository is public.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _read(String path) {
  final value = jsonDecode(File(path).readAsStringSync());
  expect(value, isA<Map<String, dynamic>>(), reason: '$path must be one JSON object');
  return value as Map<String, dynamic>;
}

// A real Stripe key is the prefix plus a long run of letters and digits.
final _realLookingKey = RegExp(r'(pk|sk|rk)_(test|live)_[A-Za-z0-9]{20,}');

void main() {
  for (final flavor in ['client', 'pro']) {
    final serverPath = 'env/$flavor.server.example.json';
    final localPath = 'env/$flavor.example.json';

    test('$serverPath parses and names the server over https', () {
      final env = _read(serverPath);
      expect(env['API_BASE_URL'], 'https://api.rawwers.com');
    });

    test('$serverPath has the same settings as $localPath', () {
      expect(_read(serverPath).keys.toSet(), _read(localPath).keys.toSet());
    });

    test('$serverPath holds no real key', () {
      final text = File(serverPath).readAsStringSync();
      expect(_realLookingKey.hasMatch(text), isFalse, reason: 'a key that looks real is in $serverPath');
      expect(text.contains('pk_live_'), isFalse);
      expect(text.contains('sk_'), isFalse);
      final env = _read(serverPath);
      if (env.containsKey('STRIPE_PUBLISHABLE_KEY')) {
        expect(env['STRIPE_PUBLISHABLE_KEY'], contains('REPLACE'));
      }
    });
  }

  test('git ignores the copies made from the examples', () {
    final ignore = File('.gitignore').readAsLinesSync();
    expect(ignore, contains('/env/*.json'));
    expect(ignore, contains('!/env/*.example.json'));
    // *.server.json is caught by /env/*.json; *.server.example.json is kept by
    // the exception above.
  });
}
