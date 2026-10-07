import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';

import '../../support/fake_http_client_adapter.dart';

/// A large file in parts, over a real socket, with the connection cut.
///
/// A localhost server stands in for R2's part endpoints and keeps what it
/// receives, so the test can check the assembled bytes; the API is faked in
/// front of it, answering "which parts do you hold" from the server's own
/// record - the same source of truth the real backend uses (list_parts).
/// R2's side of this was verified against the real bucket separately.
const _partSize = 256 * 1024;

class _Parts {
  _Parts._(this._server);

  final HttpServer _server;
  final Map<int, Uint8List> held = {};
  final Map<int, int> attempts = {};

  /// Part number -> how many of its attempts to cut off halfway.
  Map<int, int> dropPlan = {};

  static Future<_Parts> start() async {
    final parts = _Parts._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    parts._server.listen((request) async {
      final n = int.parse(request.uri.pathSegments.last);
      final attempt = parts.attempts[n] = (parts.attempts[n] ?? 0) + 1;
      final builder = BytesBuilder(copy: false);
      final length = request.contentLength;
      final drop = (parts.dropPlan[n] ?? 0) >= attempt;
      await for (final data in request) {
        builder.add(data);
        if (drop && builder.length >= length ~/ 2) {
          // The connection dies halfway through this part.
          final socket = await request.response.detachSocket(writeHeaders: false);
          socket.destroy();
          return;
        }
      }
      parts.held[n] = builder.takeBytes();
      request.response
        ..statusCode = 200
        ..headers.set('ETag', '"part-$n"')
        ..close();
    });
    return parts;
  }

  String url(int n) => 'http://${_server.address.host}:${_server.port}/part/$n';

  Future<void> close() => _server.close(force: true);
}

class _Api {
  /// How many "which parts do you hold" queries to fail before answering -
  /// a phone out of signal for a moment.
  int failPartListQueries = 0;
  final List<int> waits = [];
  int completes = 0;
  int multipartCompletes = 0;
  int aborts = 0;
  int partListQueries = 0;
}

PhotoUploadService _service(_Parts parts, _Api api, int fileSize) {
  final partCount = (fileSize + _partSize - 1) ~/ _partSize;
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
    final path = options.path;
    Future<ResponseBody> json(Object body) async => jsonResponseBody(jsonEncode(body), 200);
    if (path == '/v1/media/photos/uploads') {
      return json({
        'media_asset_id': 'asset-1',
        'upload': {'method': 'PUT', 'url': 'https://unused.invalid', 'headers': {}, 'storage_key': 'k', 'expires_in': 900},
      });
    }
    if (path.endsWith('/multipart')) return json({'part_size': _partSize, 'part_count': partCount});
    if (path.endsWith('/multipart/parts')) {
      api.partListQueries++;
      if (api.failPartListQueries > 0) {
        api.failPartListQueries--;
        throw DioException.connectionError(requestOptions: options, reason: 'no signal');
      }
      return json({
        'part_size': _partSize,
        'part_count': partCount,
        'parts': [for (final e in parts.held.entries) {'part_number': e.key, 'size': e.value.length}],
      });
    }
    if (path.endsWith('/multipart/part-urls')) {
      final numbers = (options.data is String ? jsonDecode(options.data as String) : options.data)['part_numbers'] as List;
      return json({
        'parts': [for (final n in numbers) {'part_number': n, 'url': parts.url(n as int)}],
        'expires_in': 900,
      });
    }
    if (path.endsWith('/multipart/complete')) {
      api.multipartCompletes++;
      return json({'ok': true, 'current_status': 'uploading'});
    }
    if (path.endsWith('/multipart/abort')) {
      api.aborts++;
      return json({'ok': true, 'current_status': 'uploading'});
    }
    if (path.endsWith('/complete')) {
      api.completes++;
      return json({'ok': true, 'current_status': 'processing'});
    }
    throw StateError('unexpected api call: $path');
  });
  return PhotoUploadService(
    mediaClient: MediaClient(dio),
    storageDio: Dio(),
    stallTimeout: const Duration(seconds: 5),
    partThreshold: 512 * 1024,
    retryDelay: (round) {
      api.waits.add(round);
      return Duration.zero;
    },
  );
}

Uint8List _file(int size) => Uint8List.fromList(List.generate(size, (i) => (i * 31 + 7) & 0xff));

OpenRange _rangeOf(Uint8List file) => (start, end) async* {
      // Small chunks, the way a file stream arrives.
      for (var i = start; i < end; i += 16 * 1024) {
        yield Uint8List.sublistView(file, i, i + 16 * 1024 > end ? end : i + 16 * 1024);
      }
    };

void main() {
  test('a dropped connection resumes from the part it was on, and the file arrives intact', () async {
    final parts = await _Parts.start();
    addTearDown(parts.close);
    final api = _Api();
    final file = _file(5 * _partSize + 100 * 1024); // 6 parts, the last short
    parts.dropPlan = {4: 1}; // the connection dies halfway through part 4, once

    final result = await _service(parts, api, file.length).uploadPhoto(
      openFile: () => Stream.value(file),
      openRange: _rangeOf(file),
      fileSize: file.length,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
    );

    expect(result, isA<Ok<String>>());
    expect(parts.attempts, {1: 1, 2: 1, 3: 1, 4: 2, 5: 1, 6: 1},
        reason: 'parts 1-3 had arrived and were not sent again; only part 4 was');
    final assembled = BytesBuilder();
    for (var n = 1; n <= 6; n++) {
      assembled.add(parts.held[n]!);
    }
    expect(assembled.takeBytes(), file, reason: 'byte for byte the file that was picked');
    expect(api.multipartCompletes, 1);
    expect(api.completes, 1);
    expect(api.aborts, 0);
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('a part that never gets through gives up after the rounds without progress, and aborts', () async {
    final parts = await _Parts.start();
    addTearDown(parts.close);
    final api = _Api();
    final file = _file(3 * _partSize);
    parts.dropPlan = {2: 1000};

    final result = await _service(parts, api, file.length).uploadPhoto(
      openFile: () => Stream.value(file),
      openRange: _rangeOf(file),
      fileSize: file.length,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
      maxAttempts: 3,
    );

    expect(result, isA<Err<String>>());
    expect(parts.attempts[1], 1, reason: 'part 1 got through once and was never re-sent');
    expect(parts.attempts[2], 4,
        reason: 'once in the round that also sent part 1 (which counts as progress), then once in each of three rounds without any');
    expect(api.aborts, 1, reason: 'R2 is told to drop the parts rather than keep them');
    expect(api.completes, 0);
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('a picker without ranged reads still sends each part correctly', () async {
    final parts = await _Parts.start();
    addTearDown(parts.close);
    final api = _Api();
    final file = _file(3 * _partSize + 1234);

    final result = await _service(parts, api, file.length).uploadPhoto(
      openFile: () => _rangeOf(file)(0, file.length),
      fileSize: file.length,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
    );

    expect(result, isA<Ok<String>>());
    final assembled = BytesBuilder();
    for (var n = 1; n <= 4; n++) {
      assembled.add(parts.held[n]!);
    }
    expect(assembled.takeBytes(), file);
  }, timeout: const Timeout(Duration(minutes: 1)));

  test('a small file is still one PUT, not parts', () async {
    final parts = await _Parts.start();
    addTearDown(parts.close);
    final api = _Api();
    var puts = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    dio.httpClientAdapter = FakeHttpClientAdapter((options) async {
      if (options.path == '/v1/media/photos/uploads') {
        return jsonResponseBody(
            jsonEncode({
              'media_asset_id': 'asset-1',
              'upload': {'method': 'PUT', 'url': 'https://r2.invalid/x', 'headers': {}, 'storage_key': 'k', 'expires_in': 900},
            }),
            200);
      }
      if (options.path.contains('multipart')) throw StateError('a small file must not use parts');
      return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'processing'}), 200);
    });
    final storage = Dio()..httpClientAdapter = FakeHttpClientAdapter((_) async {
      puts++;
      return ResponseBody.fromString('', 200);
    });
    final service = PhotoUploadService(mediaClient: MediaClient(dio), storageDio: storage, partThreshold: 512 * 1024);

    final result = await service.uploadPhoto(
      openFile: () => Stream.value(_file(100 * 1024)),
      fileSize: 100 * 1024,
      purpose: MediaPurpose.proof,
      contentType: 'image/jpeg',
    );

    expect(result, isA<Ok<String>>());
    expect(puts, 1);
    expect(api.completes, 0); // unused here; the fake answered complete directly
  });

  test('a moment without signal between parts waits and carries on, rather than aborting', () async {
    // Found against the real API: these failures used to be retried at once,
    // so three in a few milliseconds aborted the upload and threw away every
    // part already sent.
    final parts = await _Parts.start();
    addTearDown(parts.close);
    final api = _Api()..failPartListQueries = 2;
    final file = _file(3 * _partSize);

    final result = await _service(parts, api, file.length).uploadPhoto(
      openFile: () => Stream.value(file),
      openRange: _rangeOf(file),
      fileSize: file.length,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
      maxAttempts: 3,
    );

    expect(result, isA<Ok<String>>());
    expect(api.aborts, 0);
    expect(api.waits.take(2), [0, 1], reason: 'a wait before each retry, growing - not an instant retry');
  }, timeout: const Timeout(Duration(minutes: 1)));
}
