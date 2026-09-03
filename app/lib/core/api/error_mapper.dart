import 'package:dio/dio.dart';
import 'package:rawwers/core/api/api_failure.dart';

/// Maps a real DioException to a typed ApiFailure. Verified against the
/// live backend's two actual error shapes, not assumed:
///
/// - FastAPI/Pydantic's own 422s (no custom handler intercepts these):
///   `{"detail": [{"loc": ["body","email"], "msg": "Field required", ...}]}`
/// - Everything else (401/403/404/409/500), from the app's `APIError`:
///   `{"error": {"code": "...", "message": "...", "details": {...}}}`
ApiFailure mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const Timeout();
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return const NetworkError();
    case DioExceptionType.badResponse:
      return _mapBadResponse(exception);
  }
}

ApiFailure _mapBadResponse(DioException exception) {
  final status = exception.response?.statusCode;
  final data = exception.response?.data;

  if (status == 422) {
    return Validation(_parseValidationErrors(data));
  }
  if (status == 401) return const Unauthorized();
  if (status == 403) return const Forbidden();
  if (status == 404) return const NotFound();
  if (status == 429) return const RateLimited();
  if (status != null && status >= 500) {
    return ServerError(_envelopeMessage(data) ?? 'Server error');
  }
  return BusinessError(
    _envelopeCode(data) ?? 'unknown_error',
    _envelopeMessage(data) ?? 'Something went wrong.',
  );
}

Map<String, List<String>> _parseValidationErrors(dynamic data) {
  final result = <String, List<String>>{};
  if (data is Map && data['detail'] is List) {
    for (final item in data['detail'] as List) {
      if (item is! Map) continue;
      final loc = item['loc'];
      final field = (loc is List && loc.isNotEmpty) ? loc.last.toString() : 'unknown';
      final message = item['msg']?.toString() ?? 'Invalid value.';
      result.putIfAbsent(field, () => []).add(message);
    }
  }
  return result;
}

String? _envelopeCode(dynamic data) {
  if (data is Map && data['error'] is Map) {
    return (data['error'] as Map)['code']?.toString();
  }
  return null;
}

String? _envelopeMessage(dynamic data) {
  if (data is Map && data['error'] is Map) {
    return (data['error'] as Map)['message']?.toString();
  }
  return null;
}
