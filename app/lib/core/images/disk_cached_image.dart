import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

/// A network photo kept on the phone, recognised by *what* it is rather than
/// by the URL it happened to arrive at.
///
/// Every image the app shows comes from a signed URL, and a signature is part
/// of the URL. `Image.network` caches by URL, in memory only - so the same
/// photo with a fresh signature was a stranger, and every list load and every
/// app start downloaded every picture again. The cache key here is the URL
/// without its query string: the object's path, which names one stored file.
/// Two signatures for the same photo are the same image, in memory (through
/// [operator ==]) and on disk.
///
/// The phone keeps only what it was already shown: an image is cached when it
/// is displayed, and every URL was issued after the server checked that this
/// person may see it. A cached photo stays after access ends (a refund, say),
/// the way a photo already saved to the device does.
@immutable
class DiskCachedImage extends ImageProvider<DiskCachedImage> {
  const DiskCachedImage(this.url, {this.scale = 1.0});

  final String url;
  final double scale;

  /// The object's identity: scheme, host and path, without the signature.
  String get cacheKey {
    final uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}${uri.path}';
  }

  @override
  Future<DiskCachedImage> obtainKey(ImageConfiguration configuration) => SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(DiskCachedImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: key.scale,
      debugLabel: key.cacheKey,
    );
  }

  Future<ui.Codec> _load(DiskCachedImage key, ImageDecoderCallback decode) async {
    final bytes = await imageDiskCache.bytesFor(key.cacheKey, key.url);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) => other is DiskCachedImage && other.cacheKey == cacheKey && other.scale == scale;

  @override
  int get hashCode => Object.hash(cacheKey, scale);

  @override
  String toString() => 'DiskCachedImage($cacheKey)';
}

/// Where cached photos live, and how much room they may take.
class ImageDiskCache {
  ImageDiskCache({
    Future<Directory> Function()? directory,
    HttpClient Function()? httpClient,
    this.maxBytes = 300 * 1024 * 1024,
  })  : _directory = directory ?? _defaultDirectory,
        _httpClient = httpClient ?? HttpClient.new;

  final Future<Directory> Function() _directory;
  final HttpClient Function() _httpClient;

  /// Oldest files go first once the cache is over this.
  final int maxBytes;

  /// Requests counted since start, for verification: how many images were
  /// fetched over the network versus served from disk.
  int networkFetches = 0;
  int diskHits = 0;

  Directory? _dir;
  bool _pruned = false;
  final Map<String, Future<Uint8List>> _inFlight = {};

  static Future<Directory> _defaultDirectory() async =>
      Directory('${(await getTemporaryDirectory()).path}/photo_cache');

  Future<Directory> _ensureDir() async {
    final dir = _dir ??= await _directory();
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static String fileNameFor(String cacheKey) => sha256.convert(utf8.encode(cacheKey)).toString();

  /// The photo's bytes: from disk if this object was shown before, otherwise
  /// fetched from [url] and kept. Concurrent requests for the same photo
  /// share one download.
  Future<Uint8List> bytesFor(String cacheKey, String url) {
    // A block body, not `=> _inFlight.remove(...)`: that returns the removed
    // future, which whenComplete then waits for - this future waiting on
    // itself, forever. Every first load of every photo hung that way.
    return _inFlight[cacheKey] ??= _bytesFor(cacheKey, url).whenComplete(() {
      _inFlight.remove(cacheKey);
    });
  }

  Future<Uint8List> _bytesFor(String cacheKey, String url) async {
    final dir = await _ensureDir();
    final file = File('${dir.path}/${fileNameFor(cacheKey)}');
    if (file.existsSync()) {
      diskHits++;
      // Touch, so the oldest-first pruning means least recently shown.
      unawaited(file.setLastModified(DateTime.now()).catchError((_) {}));
      return file.readAsBytes();
    }

    networkFetches++;
    final client = _httpClient();
    try {
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 30));
      final response = await request.close().timeout(const Duration(seconds: 30));
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(cacheKey));
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      // Written whole, then renamed: a reader never sees half a file.
      final partial = File('${file.path}.part');
      await partial.writeAsBytes(bytes, flush: true);
      await partial.rename(file.path);
      if (!_pruned) {
        _pruned = true;
        unawaited(_prune(dir));
      }
      return bytes;
    } finally {
      client.close();
    }
  }

  /// Removes the least recently shown photos until the cache fits.
  Future<void> _prune(Directory dir) async {
    try {
      final files = dir.listSync().whereType<File>().where((f) => !f.path.endsWith('.part')).toList()
        ..sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      var total = files.fold<int>(0, (sum, f) => sum + f.lengthSync());
      for (final file in files) {
        if (total <= maxBytes) break;
        total -= file.lengthSync();
        file.deleteSync();
      }
    } catch (_) {
      // A cache that cannot prune itself this time is still a working cache.
    }
  }
}

/// The app's one photo cache. Replaceable in tests.
ImageDiskCache imageDiskCache = ImageDiskCache();
