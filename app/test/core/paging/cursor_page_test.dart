import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/api/error_mapper.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/core/paging/cursor_page.dart';

void main() {
  group('appendNextPage', () {
    test('appends the next page and carries the new cursor', () async {
      const current = CursorPage<String>(items: ['a'], nextCursor: 'c1');

      final next = await appendNextPage<String>(
        current,
        (cursor) async {
          expect(cursor, 'c1', reason: 'must continue from the current cursor, not restart');
          return const Ok(CursorFetchResult(items: ['b'], nextCursor: 'c2'));
        },
      );

      expect(next.items, ['a', 'b']);
      expect(next.nextCursor, 'c2');
      expect(next.isLoadingMore, isFalse);
    });

    test('a null next_cursor from the server ends the list', () async {
      const current = CursorPage<String>(items: ['a'], nextCursor: 'c1');

      final next = await appendNextPage<String>(
        current,
        (_) async => const Ok(CursorFetchResult(items: ['b'])),
      );

      expect(next.hasMore, isFalse);
    });

    test('does nothing when there is no next page', () async {
      const current = CursorPage<String>(items: ['a']);
      var called = false;

      final next = await appendNextPage<String>(current, (_) async {
        called = true;
        return const Ok(CursorFetchResult(items: []));
      });

      expect(called, isFalse);
      expect(next.items, ['a']);
    });

    test('does not stack a second request while one is in flight', () async {
      // A scroll listener near the bottom fires repeatedly; without this
      // guard the same page would be fetched and appended twice.
      const current = CursorPage<String>(items: ['a'], nextCursor: 'c1', isLoadingMore: true);
      var called = false;

      await appendNextPage<String>(current, (_) async {
        called = true;
        return const Ok(CursorFetchResult(items: ['b']));
      });

      expect(called, isFalse);
    });

    test('a failed append keeps the rows already loaded', () async {
      const current = CursorPage<String>(items: ['a', 'b'], nextCursor: 'c1');

      final next = await appendNextPage<String>(
        current,
        (_) async => const Err(NetworkError()),
      );

      expect(next.items, ['a', 'b'], reason: 'losing loaded rows because page 3 failed is worse than a retry');
      expect(next.loadMoreFailure, isA<NetworkError>());
      expect(next.hasMore, isTrue, reason: 'a network failure is retryable - the cursor is still good');
    });

    test('a rejected cursor stops paging instead of retrying it forever', () async {
      // The backend 422s an unparseable cursor rather than silently
      // restarting, so retrying the same value would loop indefinitely.
      const current = CursorPage<String>(items: ['a'], nextCursor: 'stale-cursor');

      final next = await appendNextPage<String>(
        current,
        (_) async => const Err(Validation({})),
      );

      expect(next.items, ['a']);
      expect(next.hasMore, isFalse, reason: 'must stop offering to load more with a cursor the server rejects');
      expect(next.loadMoreFailure, isNull, reason: 'this is not a retryable error, so it must not offer a retry');
    });

    test('the rejection the backend actually sends stops paging, not just a hand-built one', () async {
      // The test above builds `Validation({})` by hand, which is not what the
      // mapper produces for this response: the backend raises this through its
      // own error envelope (services/pagination.py, decode_cursor), and an
      // earlier change to the mapper quietly stopped this branch from ever
      // matching. This feeds the real body through the real mapper.
      final options = RequestOptions(path: '/v1/gigs');
      final rejection = mapDioException(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 422,
            data: {
              'error': {
                'code': 'validation_error',
                'message': 'Invalid pagination cursor. Omit the cursor to start from the first page.',
              },
            },
          ),
        ),
      );
      const current = CursorPage<String>(items: ['a'], nextCursor: 'stale-cursor');

      final next = await appendNextPage<String>(current, (_) async => Err(rejection));

      expect(next.hasMore, isFalse, reason: 'kept offering to load more with a cursor the server keeps rejecting');
      expect(next.loadMoreFailure, isNull, reason: 'offered a retry that can only fail the same way');
    });

    test('a different deliberate refusal is still retryable, not mistaken for a bad cursor', () async {
      final options = RequestOptions(path: '/v1/gigs');
      final refusal = mapDioException(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 403,
            data: {
              'error': {'code': 'forbidden', 'message': 'Role pro required'},
            },
          ),
        ),
      );
      const current = CursorPage<String>(items: ['a'], nextCursor: 'good-cursor');

      final next = await appendNextPage<String>(current, (_) async => Err(refusal));

      expect(next.hasMore, isTrue);
      expect(next.loadMoreFailure, isNotNull);
    });
  });
}
