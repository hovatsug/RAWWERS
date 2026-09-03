import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:rawwers/core/api/error_mapper.dart';
import 'package:rawwers/core/api/result.dart';

/// Wraps a generated *Client call (which returns `HttpResponse<T>` and
/// throws `DioException` on failure) into a `Result<T>` - the only crossing
/// point from dio's throwing contract to this app's non-throwing one.
Future<Result<T>> apiCall<T>(Future<HttpResponse<T>> Function() request) async {
  try {
    final response = await request();
    return Ok(response.data);
  } on DioException catch (e) {
    return Err(mapDioException(e));
  }
}
