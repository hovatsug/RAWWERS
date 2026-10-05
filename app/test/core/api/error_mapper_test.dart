// Two different things arrive as an HTTP 422, and the app has to tell them apart.
//
// FastAPI's own validation failure carries a `detail` array. But the backend
// also raises *deliberate* 422s - "could not read camera data from that file",
// "unsupported file type", "upload exceeds size limit" - through its own error
// envelope, with a message written for the person. The mapper treated every
// 422 as the first kind, so all of those messages were thrown away and a
// photographer saw "try again" for a file that could never work.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/error_mapper.dart';

DioException _bad(int status, Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  test("FastAPI's own validation failure is still field errors", () {
    final failure = mapDioException(
      _bad(422, {
        'detail': [
          {'loc': ['body', 'email'], 'msg': 'Field required'},
        ],
      }),
    );

    expect(failure, isA<Validation>());
    expect((failure as Validation).fieldErrors['email'], ['Field required']);
  });

  test('a deliberate 422 keeps the message it was written with', () {
    final failure = mapDioException(
      _bad(422, {
        'error': {'code': 'validation_error', 'message': 'Could not read camera data from that file'},
      }),
    );

    expect(failure, isA<BusinessError>(), reason: 'the message was discarded as an empty validation error');
    expect((failure as BusinessError).message, 'Could not read camera data from that file');
    expect(failure.code, 'validation_error');
    // The status is kept: 422 means "that request is invalid" and callers that
    // used to see Validation for it still need to be able to ask.
    expect(failure.status, 422);
    expect(failure.isInvalidRequest, isTrue);
  });

  test('other envelope errors are unchanged', () {
    final failure = mapDioException(
      _bad(409, {
        'error': {'code': 'conflict', 'message': 'Already registered'},
      }),
    );

    expect(failure, isA<BusinessError>());
    expect((failure as BusinessError).message, 'Already registered');
    expect(failure.status, 409);
    expect(failure.isInvalidRequest, isFalse, reason: 'a 409 is not an invalid request');
  });

  test("FastAPI's own validation failure still counts as an invalid request", () {
    final failure = mapDioException(_bad(422, {'detail': <dynamic>[]}));

    expect(failure.isInvalidRequest, isTrue);
  });

  test('a 422 with neither shape is still a validation failure, not a crash', () {
    expect(mapDioException(_bad(422, 'nonsense')), isA<Validation>());
  });
}
