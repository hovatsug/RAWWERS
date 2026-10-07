import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';

/// The photo cache against a real localhost server and a real directory.
class _Server {
  _Server._(this._server);
  final HttpServer _server;
  final List<String> requests = [];
  int failWith = 0;

  static Future<_Server> start() async {
    final s = _Server._(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
    s._server.listen((request) async {
      s.requests.add(request.uri.toString());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (s.failWith != 0) {
        request.response.statusCode = s.failWith;
      } else {
        request.response.add(Uint8List.fromList(request.uri.path.codeUnits));
      }
      await request.response.close();
    });
    return s;
  }

  String url(String path, String signature) =>
      'http://${_server.address.host}:${_server.port}$path?X-Amz-Signature=$signature';

  Future<void> close() => _server.close(force: true);
}

void main() {
  late _Server server;
  late Directory dir;
  late ImageDiskCache cache;

  setUp(() async {
    server = await _Server.start();
    dir = await Directory.systemTemp.createTemp('photo_cache_test');
    cache = ImageDiskCache(directory: () async => dir, maxBytes: 1 << 30);
  });
  tearDown(() async {
    await server.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  test('the same photo under a new signature comes from disk, not the network', () async {
    final first = server.url('/rawwers-media/a/photo_thumbnail.jpg', 'sig-one');
    final second = server.url('/rawwers-media/a/photo_thumbnail.jpg', 'sig-two');

    final a = await cache.bytesFor(DiskCachedImage(first).cacheKey, first);
    final b = await cache.bytesFor(DiskCachedImage(second).cacheKey, second);

    expect(b, a);
    expect(server.requests, hasLength(1), reason: 'the second signature named the same object');
    expect((cache.networkFetches, cache.diskHits), (1, 1));
    expect(DiskCachedImage(first), DiskCachedImage(second), reason: "so Flutter's memory cache treats them as one image too");
  });

  test('different photos are kept apart', () async {
    final a = server.url('/rawwers-media/a.jpg', 's');
    final b = server.url('/rawwers-media/b.jpg', 's');

    final bytesA = await cache.bytesFor(DiskCachedImage(a).cacheKey, a);
    final bytesB = await cache.bytesFor(DiskCachedImage(b).cacheKey, b);

    expect(bytesA, isNot(bytesB));
    expect(server.requests, hasLength(2));
    expect(DiskCachedImage(a), isNot(DiskCachedImage(b)));
  });

  test('a refused request caches nothing, so a later one can still succeed', () async {
    final url = server.url('/rawwers-media/expired.jpg', 'old');
    server.failWith = 403;

    await expectLater(cache.bytesFor(DiskCachedImage(url).cacheKey, url), throwsA(isA<HttpException>()));
    expect(dir.listSync(), isEmpty);

    server.failWith = 0;
    await cache.bytesFor(DiskCachedImage(url).cacheKey, url);
    expect(server.requests, hasLength(2));
  });

  test('two widgets asking for one photo at once share one download', () async {
    final url = server.url('/rawwers-media/shared.jpg', 's');
    final key = DiskCachedImage(url).cacheKey;

    await Future.wait([cache.bytesFor(key, url), cache.bytesFor(key, url), cache.bytesFor(key, url)]);

    expect(server.requests, hasLength(1));
  });

  test('over its size limit, the least recently shown photos go first', () async {
    cache = ImageDiskCache(directory: () async => dir, maxBytes: 60);
    final old = File('${dir.path}/${ImageDiskCache.fileNameFor('old')}')
      ..writeAsBytesSync(List.filled(50, 1))
      ..setLastModifiedSync(DateTime(2020));
    final recent = File('${dir.path}/${ImageDiskCache.fileNameFor('recent')}')
      ..writeAsBytesSync(List.filled(20, 1))
      ..setLastModifiedSync(DateTime(2025));

    final url = server.url('/rawwers-media/new.jpg', 's');
    await cache.bytesFor(DiskCachedImage(url).cacheKey, url);
    await Future<void>.delayed(const Duration(milliseconds: 100)); // pruning runs after the write

    expect(old.existsSync(), isFalse, reason: 'oldest first');
    expect(recent.existsSync(), isTrue);
  });
}
