// Saving a bought photo to the device.
//
// What matters is that no failure is silent and none is misnamed: a denied
// permission sends someone to Settings, a dropped connection asks them to try
// again, and telling one as the other sends them the wrong way. Storage and
// the photo library are both stubbed, so every branch is reached for real
// rather than asserted about.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gal/gal.dart';
import 'package:rawwers/core/download/photo_saver.dart';

class _Library implements PhotoLibrary {
  _Library({this.access = true, this.putError});

  final bool access;
  final Object? putError;
  final saved = <String>[];
  String? savedBytesOf;

  @override
  Future<bool> ensureAccess() async => access;

  @override
  Future<void> putImage(String path) async {
    if (putError case final error?) throw error;
    saved.add(path);
    savedBytesOf = File(path).readAsStringSync();
  }
}

/// Storage, answering with [status] and [body], or failing the connection.
class _Storage implements HttpClientAdapter {
  _Storage({this.status = 200, this.dropConnection = false});

  static const body = 'JPEGDATA';

  final int status;
  final bool dropConnection;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? _, Future<void>? _) async {
    requests.add(options);
    if (dropConnection) throw const SocketException('connection reset');
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentLengthHeader: ['${body.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

GalException _gal(GalExceptionType type) => GalException(
      type: type,
      platformException: PlatformException(code: type.code),
      stackTrace: StackTrace.empty,
    );

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('photo_saver_test'));
  tearDown(() => temp.deleteSync(recursive: true));

  PhotoSaver saver(_Storage storage, _Library library) => PhotoSaver(
        storageDio: Dio()..httpClientAdapter = storage,
        library: library,
        tempDirectory: () async => temp,
      );

  const url = 'https://bucket.test/users/u/finals/abc.jpg?X-Amz-Signature=sig';

  test('a photo that downloads and is accepted is saved, with progress', () async {
    final storage = _Storage();
    final library = _Library();
    final progress = <double>[];

    final outcome = await saver(storage, library).save(url, name: 'RAWWERS-a1', onProgress: progress.add);

    expect(outcome, isA<Saved>());
    expect(library.savedBytesOf, 'JPEGDATA');
    expect(library.saved.single, endsWith('RAWWERS-a1.jpg'), reason: 'the library picks a decoder by extension');
    expect(progress.last, 1.0);
  });

  test('the signed link is fetched bare - no Authorization header', () async {
    // A presigned URL carries its own auth. A second method is refused by
    // storage, and would hand the session token to a third party.
    final storage = _Storage();
    await saver(storage, _Library()).save(url, name: 'x');
    expect(storage.requests.single.headers.keys.map((k) => k.toLowerCase()), isNot(contains('authorization')));
  });

  test('permission refused: says so, and downloads nothing', () async {
    final storage = _Storage();
    final outcome = await saver(storage, _Library(access: false)).save(url, name: 'x');

    expect((outcome as SaveFailed).reason, SaveFailure.permissionDenied);
    expect(storage.requests, isEmpty, reason: 'a full-resolution download the person cannot keep');
  });

  test('connection dropped: a network failure', () async {
    final outcome = await saver(_Storage(dropConnection: true), _Library()).save(url, name: 'x');
    expect((outcome as SaveFailed).reason, SaveFailure.network);
  });

  test('storage refusing the link: the link, not the connection', () async {
    for (final status in [403, 404]) {
      final outcome = await saver(_Storage(status: status), _Library()).save(url, name: 'x');
      expect((outcome as SaveFailed).reason, SaveFailure.linkUnavailable, reason: 'HTTP $status');
    }
  });

  test('a server error from storage is treated as retryable', () async {
    final outcome = await saver(_Storage(status: 500), _Library()).save(url, name: 'x');
    expect((outcome as SaveFailed).reason, SaveFailure.network);
  });

  test('the library refusing the file maps to what the person can do about it', () async {
    final cases = {
      GalExceptionType.accessDenied: SaveFailure.permissionDenied,
      GalExceptionType.notEnoughSpace: SaveFailure.notEnoughSpace,
      GalExceptionType.notSupportedFormat: SaveFailure.storage,
      GalExceptionType.unexpected: SaveFailure.storage,
    };
    for (final MapEntry(key: type, value: expected) in cases.entries) {
      final outcome = await saver(_Storage(), _Library(putError: _gal(type))).save(url, name: 'x');
      expect((outcome as SaveFailed).reason, expected, reason: '$type');
    }
  });

  test('anything else the library throws is still a failure, not a crash', () async {
    final outcome = await saver(_Storage(), _Library(putError: StateError('boom'))).save(url, name: 'x');
    expect((outcome as SaveFailed).reason, SaveFailure.storage);
  });

  test('the temp copy is removed whether or not the save worked', () async {
    await saver(_Storage(), _Library()).save(url, name: 'ok');
    await saver(_Storage(), _Library(putError: _gal(GalExceptionType.unexpected))).save(url, name: 'failed');
    expect(temp.listSync(), isEmpty);
  });

  test('every failure has words of its own', () {
    final messages = SaveFailure.values.map((f) => f.message).toSet();
    expect(messages, hasLength(SaveFailure.values.length));
    for (final message in messages) {
      expect(message, isNotEmpty);
    }
  });
}
