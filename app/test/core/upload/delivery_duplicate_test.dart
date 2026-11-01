// Phone deliveries name their gallery and the SHA-256 of the file, so the
// server's duplicate check (the one the Lightroom plug-in uses) covers them.
//
// The server side - the same file in a gallery is the photo already there, an
// upload without the fields is a new photo, a half-finished one is resumed -
// is tested in api/tests/test_delivery_uploads.py. Here: what the app sends,
// that the hash is of the exact bytes it sends, read as a stream, and that a
// file already there is not sent again.
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';

import '../../support/fake_http_client_adapter.dart';

class _Server {
  final creates = <Map<String, dynamic>>[];
  final puts = <List<int>>[];
  var completes = 0;
  var duplicate = false;

  /// Answer the first N creates with a dropped connection.
  var dropCreates = 0;

  Dio api() => Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = FakeHttpClientAdapter((o) async {
      if (o.path == '/v1/media/photos/uploads') {
        creates.add(Map<String, dynamic>.from(jsonDecode(jsonEncode(o.data)) as Map));
        if (dropCreates > 0) {
          dropCreates--;
          throw DioException(requestOptions: o, type: DioExceptionType.connectionError);
        }
        if (duplicate) return jsonResponseBody(jsonEncode({'media_asset_id': 'asset-1', 'upload': null, 'duplicate': true}), 200);
        return jsonResponseBody(
          jsonEncode({
            'media_asset_id': 'asset-1',
            'upload': {'method': 'PUT', 'url': 'https://storage.invalid/put', 'headers': {'Content-Type': 'image/jpeg'}, 'storage_key': 'k', 'expires_in': 900},
          }),
          200,
        );
      }
      if (o.path.endsWith('/complete')) {
        completes++;
        return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'processing'}), 200);
      }
      throw StateError('unexpected ${o.path}');
    });

  Dio storage() => Dio()
    ..httpClientAdapter = FakeHttpClientAdapter((o) async {
      final body = <int>[];
      await for (final chunk in o.data as Stream<List<int>>) {
        body.addAll(chunk);
      }
      puts.add(body);
      return ResponseBody.fromString('', 200);
    });
}

/// A file read in many pieces, counting how many times it was opened.
class _File {
  _File(this.bytes, {this.piece = 1000});
  final Uint8List bytes;
  final int piece;
  var opened = 0;

  Stream<Uint8List> open() async* {
    opened++;
    for (var i = 0; i < bytes.length; i += piece) {
      yield Uint8List.sublistView(bytes, i, i + piece > bytes.length ? bytes.length : i + piece);
    }
  }
}

Uint8List _bytes(int n) => Uint8List.fromList(List.generate(n, (i) => (i * 31 + 7) % 256));

Future<Result<String>> _upload(_Server server, _File file, {String? galleryId, MediaPurpose purpose = MediaPurpose.proof}) =>
    PhotoUploadService(mediaClient: MediaClient(server.api()), storageDio: server.storage(), retryDelay: (_) => Duration.zero)
        .uploadPhoto(
      openFile: file.open,
      fileSize: file.bytes.length,
      purpose: purpose,
      contentType: 'image/jpeg',
      fileName: 'IMG_1.jpg',
      galleryId: galleryId,
    );

void main() {
  test('a delivery names its gallery and the SHA-256 of the exact bytes it sends', () async {
    final server = _Server();
    final file = _File(_bytes(25000));

    final result = await _upload(server, file, galleryId: 'gallery-1');

    expect(result, isA<Ok<String>>());
    expect(server.creates.single['gallery_id'], 'gallery-1');
    expect(server.creates.single['sha256'], sha256.convert(server.puts.single).toString());
    expect(server.puts.single, file.bytes);
  });

  test('the file is hashed as a stream, piece by piece, and read again to send', () async {
    final server = _Server();
    final file = _File(_bytes(250000), piece: 4096);

    await _upload(server, file, galleryId: 'gallery-1');

    expect(file.opened, 2, reason: 'once to hash, once to send: never held whole in memory');
    expect(server.creates.single['sha256'], sha256.convert(file.bytes).toString());
  });

  test('a file the gallery already has is not sent again', () async {
    final server = _Server()..duplicate = true;
    final file = _File(_bytes(5000));

    final result = await _upload(server, file, galleryId: 'gallery-1');

    expect(result, isA<Ok<String>>());
    expect((result as Ok<String>).value, 'asset-1', reason: 'the photo already there');
    expect(server.puts, isEmpty);
    expect(server.completes, 0);
  });

  test('a retry after a lost connection names the same file, so the server keeps one photo', () async {
    final server = _Server()..dropCreates = 1;
    final file = _File(_bytes(5000));

    final result = await _upload(server, file, galleryId: 'gallery-1');

    expect(result, isA<Ok<String>>());
    expect(server.creates, hasLength(2));
    expect(server.creates[0]['sha256'], server.creates[1]['sha256']);
    expect(server.creates[0]['gallery_id'], server.creates[1]['gallery_id']);
    expect(server.puts, hasLength(1));
  });

  test('anything but a delivery sends neither field, as before', () async {
    final server = _Server();
    final file = _File(_bytes(5000));

    await _upload(server, file, purpose: MediaPurpose.portfolioReel);

    expect(server.creates.single.containsKey('sha256') ? server.creates.single['sha256'] : null, isNull);
    expect(server.creates.single.containsKey('gallery_id') ? server.creates.single['gallery_id'] : null, isNull);
    expect(file.opened, 1, reason: 'no hashing pass when no gallery is named');
  });
}
