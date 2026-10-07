import 'dart:async';
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

/// A slow connection, for real: a localhost server that reads the upload at a
/// fixed pace, so socket backpressure holds the real Dio IO adapter back the
/// way a slow uplink does. The fake adapter used elsewhere never reads the
/// body, and Dio enforces its send timeout inside the real adapter - so the
/// whole-upload timeout this replaces was invisible to every other test.
///
/// Scaled down: a 32 MB body read over about four seconds against a one-second
/// stall window stands for a 58 MB RAW taking twelve minutes against a
/// five-minute limit.
const _chunk = 64 * 1024;
const _bodyBytes = 32 * 1024 * 1024;

Stream<Uint8List> _body() async* {
  final chunk = Uint8List(_chunk);
  for (var sent = 0; sent < _bodyBytes; sent += _chunk) {
    yield chunk;
  }
}

class _Storage {
  _Storage._(this._server);

  final HttpServer _server;
  int requests = 0;
  final List<int> bytesReceived = [];

  static Future<_Storage> start({required int bytesPerSecond, int? stopAfterBytes, Duration answerAfter = Duration.zero}) async {
    final storage = _Storage._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    storage._server.listen((request) {
      storage.requests++;
      var received = 0;
      late StreamSubscription<List<int>> sub;
      sub = request.listen(
        (data) {
          received += data.length;
          if (stopAfterBytes != null && received >= stopAfterBytes) {
            // Stop reading and never answer: the connection is alive and
            // nothing moves. Exactly what a dead mobile link looks like.
            sub.pause();
            storage.bytesReceived.add(received);
            return;
          }
          // Paced by bytes, not by event: loopback delivers events of very
          // different sizes, so a fixed pause per event is no rate at all.
          sub.pause();
          Future.delayed(Duration(microseconds: data.length * 1000000 ~/ bytesPerSecond), sub.resume);
        },
        onDone: () async {
          storage.bytesReceived.add(received);
          await Future<void>.delayed(answerAfter);
          request.response
            ..statusCode = 200
            ..close();
        },
      );
    });
    return storage;
  }

  String get url => 'http://${_server.address.host}:${_server.port}/upload';

  Future<void> close() => _server.close(force: true);
}

PhotoUploadService _service(String putUrl, Duration stallTimeout) {
  final apiDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
  var created = 0;
  apiDio.httpClientAdapter = FakeHttpClientAdapter((options) async {
    if (options.path == '/v1/media/photos/uploads') {
      created++;
      return jsonResponseBody(
        jsonEncode({
          'media_asset_id': 'asset-$created',
          'upload': {'method': 'PUT', 'url': putUrl, 'headers': {}, 'storage_key': 'k', 'expires_in': 900},
        }),
        200,
      );
    }
    if (options.path.endsWith('/upload-url')) {
      // A retry's fresh URL for the same asset.
      return jsonResponseBody(
        jsonEncode({'method': 'PUT', 'url': putUrl, 'headers': {}, 'storage_key': 'k', 'expires_in': 900}),
        200,
      );
    }
    return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'processing'}), 200);
  });
  // One PUT, whatever the size: these are about the single-request path's
  // timeout. The parts path shares the same watchdog (upload_parts_test).
  return PhotoUploadService(
    mediaClient: MediaClient(apiDio),
    storageDio: Dio(),
    stallTimeout: stallTimeout,
    partThreshold: 1 << 40,
  );
}

void main() {
  test('a slow but steady upload finishes however long it takes', () async {
    // 8 MB/s: about four seconds for the body.
    final storage = await _Storage.start(bytesPerSecond: 8 * 1024 * 1024);
    addTearDown(storage.close);
    final clock = Stopwatch()..start();

    final result = await _service(storage.url, const Duration(seconds: 1)).uploadPhoto(
      openFile: _body,
      fileSize: _bodyBytes,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
      maxAttempts: 1,
    );

    expect(result, isA<Ok<String>>());
    expect(storage.bytesReceived, [_bodyBytes], reason: 'the whole file, in one attempt');
    expect(clock.elapsed, greaterThan(const Duration(seconds: 2)),
        reason: 'the transfer must outlast the stall window several times over, or this proves nothing');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('an upload that stops moving is abandoned after the stall window, and retried', () async {
    final storage = await _Storage.start(bytesPerSecond: 1 << 40, stopAfterBytes: 4 * 1024 * 1024);
    addTearDown(storage.close);
    final clock = Stopwatch()..start();

    final result = await _service(storage.url, const Duration(seconds: 1)).uploadPhoto(
      openFile: _body,
      fileSize: _bodyBytes,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
      maxAttempts: 2,
    );

    expect(result, isA<Err<String>>());
    expect(storage.requests, 2, reason: 'a stall is retried, not given up on at once');
    expect(clock.elapsed, lessThan(const Duration(seconds: 20)), reason: 'abandoned at the stall window, not hung forever');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('a slow answer after the last byte is not mistaken for a stall', () async {
    // Found against real R2: after the last byte is handed to the socket the
    // bytes still have to drain from the send buffer - megabytes on a phone -
    // and R2 has to answer, with no progress events in between. A stall
    // timer still running then cancelled an upload that was fine.
    final storage = await _Storage.start(bytesPerSecond: 1 << 40, answerAfter: const Duration(seconds: 3));
    addTearDown(storage.close);

    final result = await _service(storage.url, const Duration(seconds: 1)).uploadPhoto(
      openFile: _body,
      fileSize: _bodyBytes,
      purpose: MediaPurpose.gearEvidence,
      contentType: 'application/octet-stream',
      maxAttempts: 1,
    );

    expect(result, isA<Ok<String>>());
    expect(storage.requests, 1);
  }, timeout: const Timeout(Duration(minutes: 1)));
}
