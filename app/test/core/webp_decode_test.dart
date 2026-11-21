import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// Cards, tiles and the profile header show the server's card copy, a WebP
/// (2026-11-20). The engine's own codec decodes it - the same one the apps
/// use on iOS and Android - so no package is needed.
void main() {
  test('a WebP card copy decodes', () async {
    final bytes = base64Decode('UklGRjoAAABXRUJQVlA4IC4AAACQAQCdASoMAAgAAUAmJaACdLoAA5gA/vCbQ/4DdfFtMv/ucD/uyf/2yf+pAAAA');
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 12);
    expect(frame.image.height, 8);
  });
}
