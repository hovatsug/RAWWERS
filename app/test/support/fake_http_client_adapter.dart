import 'dart:typed_data';

import 'package:dio/dio.dart';

typedef FakeHandler = Future<ResponseBody> Function(RequestOptions options);

/// A hand-rolled dio HttpClientAdapter for tests - no mock-http dependency
/// needed, just dio's own adapter interface.
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.handler);

  final FakeHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponseBody(String json, int statusCode) {
  return ResponseBody.fromString(
    json,
    statusCode,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}
