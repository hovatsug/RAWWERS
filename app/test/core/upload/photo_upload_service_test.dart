import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';

import '../../support/fake_http_client_adapter.dart';

void main() {
  test('a failed PUT never retries the same presigned URL - retry goes back to step 1 for a fresh one', () async {
    var createCallCount = 0;
    var completeCallCount = 0;
    final putUrlsAttempted = <String>[];

    final apiDio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));
    apiDio.httpClientAdapter = FakeHttpClientAdapter((options) async {
      if (options.path == '/v1/media/photos/uploads') {
        createCallCount++;
        final url = 'https://storage.invalid/upload-$createCallCount';
        return jsonResponseBody(
          jsonEncode({
            'media_asset_id': 'asset-$createCallCount',
            'upload': {
              'method': 'PUT',
              'url': url,
              'headers': {'Content-Type': 'image/jpeg'},
              'storage_key': 'key-$createCallCount',
              'expires_in': 900,
            },
          }),
          200,
        );
      }
      if (options.path.contains('/complete')) {
        completeCallCount++;
        return jsonResponseBody(jsonEncode({'ok': true, 'current_status': 'processing'}), 200);
      }
      throw StateError('unexpected api call: ${options.path}');
    });

    final storageDio = Dio();
    storageDio.httpClientAdapter = FakeHttpClientAdapter((options) async {
      putUrlsAttempted.add(options.uri.toString());
      // Fail the first two PUT attempts, succeed on the third.
      if (putUrlsAttempted.length < 3) {
        return ResponseBody.fromString('forbidden', 403);
      }
      return ResponseBody.fromString('', 200);
    });

    final service = PhotoUploadService(mediaClient: MediaClient(apiDio), storageDio: storageDio);

    final result = await service.uploadPhoto(
      openFile: () => Stream.value(Uint8List.fromList([1, 2, 3])),
      fileSize: 3,
      purpose: MediaPurpose.portfolioReel,
      contentType: 'image/jpeg',
    );

    expect(result, isA<Ok<String>>());
    expect((result as Ok<String>).value, 'asset-3', reason: 'the asset from the attempt whose PUT actually succeeded');

    expect(createCallCount, 3, reason: 'each retry must request a fresh presigned URL, not reuse the failed one');
    expect(completeCallCount, 1, reason: 'complete is only ever called once, for the attempt that succeeded');
    expect(
      putUrlsAttempted.toSet().length,
      3,
      reason: 'every PUT attempt must target a distinct URL - retrying the same expired/consumed URL is the bug this guards against',
    );
  });
}
