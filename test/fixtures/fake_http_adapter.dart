import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A dependency-free [HttpClientAdapter] that returns canned JSON based on the
/// request URL, so we can exercise the real Dio + DTO parsing path in tests
/// without a mock library or network access.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.route);

  /// Maps a request to a `(statusCode, jsonBody)` pair. Return a status >= 400
  /// to make Dio raise a [DioException]; throw to simulate a transport failure.
  final FakeResponse Function(RequestOptions options) route;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final FakeResponse res = route(options);
    return ResponseBody.fromString(
      res.body,
      res.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeResponse {
  const FakeResponse(this.statusCode, this.body);
  final int statusCode;
  final String body;
}

/// Builds a [Dio] wired to a [FakeHttpAdapter] with the given router.
Dio fakeDio(FakeResponse Function(RequestOptions options) route) {
  return Dio(BaseOptions())..httpClientAdapter = FakeHttpAdapter(route);
}
