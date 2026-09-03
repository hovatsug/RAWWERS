import 'package:rawwers/core/api/api_failure.dart';

/// Every API call returns this - never a thrown exception. Exhaustive via
/// Dart 3 sealed-class switch:
/// ```dart
/// switch (result) {
///   case Ok(value: final v): ...
///   case Err(failure: final f): ...
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final ApiFailure failure;
}
