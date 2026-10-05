/// Typed transport failures. Every generated API call goes through
/// [mapDioException] (see error_mapper.dart) to reach one of these -
/// nothing throws a DioException across the API boundary.
sealed class ApiFailure {
  const ApiFailure();
}

final class Unauthorized extends ApiFailure {
  const Unauthorized();
}

final class Forbidden extends ApiFailure {
  const Forbidden();
}

final class NotFound extends ApiFailure {
  const NotFound();
}

final class Validation extends ApiFailure {
  const Validation(this.fieldErrors);

  /// Field name (last segment of Pydantic's `loc`) to its messages.
  final Map<String, List<String>> fieldErrors;
}

final class RateLimited extends ApiFailure {
  const RateLimited();
}

/// A 4xx the backend raised deliberately (its custom `{"error": {code,
/// message}}` envelope) that isn't one of the specific cases above - a
/// business-rule rejection like "duplicate email" or "niche cap exceeded".
/// Not in the original F-3 spec's fixed list; added because the backend's
/// error envelope carries a machine-readable `code` for exactly this case,
/// and dropping it into ServerError would misrepresent a 4xx as an infra
/// failure and lose the message.
final class BusinessError extends ApiFailure {
  const BusinessError(this.code, this.message, {this.status});

  final String code;
  final String message;

  /// The HTTP status it arrived with, when known. Kept because a 422 from the
  /// backend's own error envelope means "that request is invalid" - what
  /// [Validation] meant before deliberate 422s were given their messages - and
  /// callers written against that meaning still need to be able to ask.
  final int? status;
}

extension ApiFailureX on ApiFailure {
  /// The server judged the request itself invalid (HTTP 422), whether by
  /// FastAPI's own validation or by a deliberate rule with a message.
  ///
  /// Use this where the question is "was that request malformed", as opposed
  /// to matching [Validation] alone, which no longer covers the deliberate
  /// kind now that those carry their message as a [BusinessError].
  bool get isInvalidRequest => switch (this) {
        Validation() => true,
        BusinessError(:final status) => status == 422,
        _ => false,
      };
}

final class ServerError extends ApiFailure {
  const ServerError(this.message);

  final String message;
}

final class NetworkError extends ApiFailure {
  const NetworkError();
}

final class Timeout extends ApiFailure {
  const Timeout();
}
