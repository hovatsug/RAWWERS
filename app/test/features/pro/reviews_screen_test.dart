// A photographer's own reviews, and their one reply to each.
//
// The list is the public one - what clients read - so a reply appears here
// exactly as a client will see it. A reply is write-once on the server, so a
// review that has one offers no reply button, and a reply is shown as posted
// only once the refetched list carries it.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/reviews_client.dart';
import 'package:rawwers/api/models/me_response.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/reviews/reviews_screen.dart';

import '../../support/fake_http_client_adapter.dart';

const _me = 'pro-me';

class _SignedIn extends AuthController {
  @override
  Future<AuthState> build() async => const AuthAuthenticated(MeResponse(userId: _me, status: 'active'));
}

class _Backend {
  final reviews = <Map<String, dynamic>>[];
  final replies = <String, String>{};
  final requestedFor = <String>[];
  ({int status, String code, String message})? refuseReply;

  void add(String id, {required int rating, String? text}) => reviews.add({
        'id': id,
        'rating': rating,
        'text': text,
        'would_book_again': true,
        'niche': {'slug': 'weddings', 'name': 'Weddings'},
        'created_at': '2026-09-29T12:00:00Z',
      });

  Future<ResponseBody> handle(RequestOptions o) async {
    final list = RegExp(r'^/v1/pros/([^/]+)/reviews$').firstMatch(o.uri.path);
    if (o.method == 'GET' && list != null) {
      requestedFor.add(list.group(1)!);
      final items = [
        for (final r in reviews)
          {
            ...r,
            'reply': replies[r['id']] == null
                ? null
                : {
                    'id': 'reply-${r['id']}',
                    'review_id': r['id'],
                    'pro_user_id': _me,
                    'text': replies[r['id']],
                    'created_at': '2026-09-30T09:00:00Z',
                    'updated_at': '2026-09-30T09:00:00Z',
                  },
          },
      ];
      return jsonResponseBody(jsonEncode({'total': items.length, 'items': items}), 200);
    }
    final reply = RegExp(r'^/v1/reviews/([^/]+)/reply$').firstMatch(o.uri.path);
    if (o.method == 'POST' && reply != null) {
      if (refuseReply case final r?) {
        return jsonResponseBody(jsonEncode({'error': {'code': r.code, 'message': r.message}}), r.status);
      }
      final body = (o.data is String ? jsonDecode(o.data as String) : o.data) as Map<String, dynamic>;
      final id = reply.group(1)!;
      replies[id] = body['text'] as String;
      return jsonResponseBody(
        jsonEncode({
          'id': 'reply-$id',
          'review_id': id,
          'pro_user_id': _me,
          'text': replies[id],
          'created_at': '2026-09-30T09:00:00Z',
          'updated_at': '2026-09-30T09:00:00Z',
        }),
        200,
      );
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

Future<void> _pump(WidgetTester tester, _Backend backend) async {
  tester.view.physicalSize = const Size(1170, 4200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_SignedIn.new),
        reviewsClientProvider.overrideWithValue(ReviewsClient(dio)),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const ProReviewsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _reply(WidgetTester tester, String text) async {
  await tester.tap(find.widgetWithText(OutlinedButton, 'Reply'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Post reply'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows my own reviews, as clients see them', (tester) async {
    final backend = _Backend()..add('r1', rating: 5, text: 'Wonderful day');
    await _pump(tester, backend);

    expect(backend.requestedFor, everyElement(_me), reason: "asked for someone else's reviews");
    expect(find.text('Wonderful day'), findsOneWidget);
    expect(find.textContaining('Verified booking · Weddings'), findsOneWidget);
  });

  testWidgets('no reviews yet says so plainly', (tester) async {
    await _pump(tester, _Backend());
    expect(find.text('No reviews yet'), findsOneWidget);
  });

  testWidgets('a reply is shown once the server has it, and cannot be written twice', (tester) async {
    final backend = _Backend()..add('r1', rating: 4, text: 'Good');
    await _pump(tester, backend);

    await _reply(tester, '  Thanks for having me!  ');

    expect(backend.replies['r1'], 'Thanks for having me!', reason: 'sent trimmed');
    expect(find.text('Thanks for having me!'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Reply'), findsNothing, reason: 'the server takes one reply per review');
  });

  testWidgets('a review that already has a reply offers no reply button', (tester) async {
    final backend = _Backend()
      ..add('r1', rating: 5, text: 'Great')
      ..add('r2', rating: 3, text: 'Fine')
      ..replies['r1'] = 'Thank you';
    await _pump(tester, backend);

    expect(find.widgetWithText(OutlinedButton, 'Reply'), findsOneWidget, reason: 'only the unanswered one');
  });

  testWidgets('an empty reply cannot be posted', (tester) async {
    final backend = _Backend()..add('r1', rating: 4);
    await _pump(tester, backend);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reply'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Post reply')).onPressed, isNull);
  });

  testWidgets('a refused reply says why and keeps the words', (tester) async {
    final backend = _Backend()
      ..add('r1', rating: 4)
      ..refuseReply = (status: 409, code: 'invalid_state', message: 'Cannot reply to a hidden or removed review');
    await _pump(tester, backend);
    await _reply(tester, 'My words');

    expect(find.text('Cannot reply to a hidden or removed review'), findsOneWidget);
    expect(find.text('My words'), findsOneWidget);
  });

  testWidgets('already replied elsewhere: the form closes and the list shows that reply', (tester) async {
    final backend = _Backend()
      ..add('r1', rating: 4)
      ..refuseReply = (status: 409, code: 'already_exists', message: 'Review reply already exists');
    await _pump(tester, backend);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reply'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Second try');
    await tester.pump();
    backend.replies['r1'] = 'Replied from the laptop';
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post reply'));
    await tester.pumpAndSettle();

    expect(find.text("You've already replied to this review."), findsOneWidget);
    expect(find.text('Replied from the laptop'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Reply'), findsNothing);
  });
}
