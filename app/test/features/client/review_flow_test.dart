// Leaving a review, from the client's side.
//
// Every state here comes from the server. When a review may be written is the
// backend's rule (`_is_reviewable_gig`: completed or final_delivered), whether
// one exists is the booking's `review` field, and "you reviewed this" is shown
// only once the server says so - never from a local flag set on submit. So the
// tests run the real clients against a fake backend and check what goes over
// the wire, not what a controller was handed.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/api/api_client/reviews_client.dart';
import 'package:rawwers/api/models/client_pro_profile_response.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_client.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_controller.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_screen.dart';

import '../../support/fake_http_client_adapter.dart';

const _bookingId = 'b-1';
const _gigId = 'g-1';
const _proId = 'pro-1';

/// The server, as far as reviews go. Mutable, so a submission changes what
/// the next booking fetch returns - the only way the screen may learn of it.
class _Backend {
  _Backend({this.gigStatus = 'completed', this.bookingStatusCode = 200});

  String? gigStatus;
  int bookingStatusCode;
  Map<String, dynamic>? review;

  /// What POST /gigs/{id}/review answers, when set. Null means accept it.
  ({int status, String code, String message})? refuseReview;
  final posted = <Map<String, dynamic>>[];

  Map<String, dynamic> reviewJson({
    required int rating,
    String? text,
    required bool wouldBookAgain,
    String status = 'published',
    String? reply,
  }) =>
      {
        'id': 'r-1',
        'gig_id': _gigId,
        'pro_user_id': _proId,
        'client_user_id': 'client-1',
        'niche_id': 'n-1',
        'rating': rating,
        'tags': <String>[],
        'text': text,
        'would_book_again': wouldBookAgain,
        'status': status,
        'created_at': '2026-09-29T12:00:00Z',
        'updated_at': '2026-09-29T12:00:00Z',
        'reply': reply == null
            ? null
            : {
                'id': 'rr-1',
                'review_id': 'r-1',
                'pro_user_id': _proId,
                'text': reply,
                'created_at': '2026-09-30T09:00:00Z',
                'updated_at': '2026-09-30T09:00:00Z',
              },
      };

  Future<ResponseBody> handle(RequestOptions o) async {
    final path = o.uri.path;
    if (o.method == 'GET' && path == '/v1/client/bookings/$_bookingId') {
      if (bookingStatusCode != 200) {
        return jsonResponseBody(
          jsonEncode({
            'error': {'code': 'forbidden', 'message': 'Not allowed'},
          }),
          bookingStatusCode,
        );
      }
      return jsonResponseBody(
        jsonEncode({
          'booking_id': _bookingId,
          'booking_status': 'accepted',
          'gig_id': gigStatus == null ? null : _gigId,
          'gig_status': gigStatus,
          'payment_status': gigStatus == null ? null : 'succeeded',
          'timeline': <Object>[],
          'next_actions': <Object>[],
          'review': review,
        }),
        200,
      );
    }
    if (o.method == 'POST' && path == '/v1/gigs/$_gigId/review') {
      final body = (o.data is String ? jsonDecode(o.data as String) : o.data) as Map<String, dynamic>;
      posted.add(body);
      if (refuseReview case final r?) {
        return jsonResponseBody(
          jsonEncode({
            'error': {'code': r.code, 'message': r.message},
          }),
          r.status,
        );
      }
      review = reviewJson(
        rating: body['rating'] as int,
        text: body['text'] as String?,
        wouldBookAgain: body['would_book_again'] as bool,
      );
      return jsonResponseBody(jsonEncode(review), 200);
    }
    if (o.method == 'GET' && path == '/v1/pros/$_proId/reviews') {
      final r = review;
      final public = r == null || r['status'] != 'published'
          ? <Map<String, dynamic>>[]
          : [
              {
                'id': r['id'],
                'rating': r['rating'],
                'text': r['text'],
                'would_book_again': r['would_book_again'],
                'niche': {'slug': 'weddings', 'name': 'Weddings'},
                'created_at': r['created_at'],
                'reply': r['reply'],
              },
            ];
      return jsonResponseBody(jsonEncode({'total': public.length, 'items': public}), 200);
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }

  Dio dio() => Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(handle);
}

Future<void> _pumpBooking(WidgetTester tester, _Backend backend, {List<Override> extra = const []}) async {
  tester.view.physicalSize = const Size(1170, 4200);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final dio = backend.dio();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clientLaunchClientProvider.overrideWithValue(ClientLaunchClient(dio)),
        reviewsClientProvider.overrideWithValue(ReviewsClient(dio)),
        ...extra,
      ],
      child: MaterialApp(theme: buildClientTheme(), home: const BookingDetailScreen(bookingId: _bookingId)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('when the prompt appears', () {
    for (final status in [null, 'payment_pending', 'paid', 'scheduled', 'shoot_done', 'proofs_delivered', 'selection_pending', 'cancelled', 'disputed']) {
      testWidgets('not while the gig is $status', (tester) async {
        await _pumpBooking(tester, _Backend(gigStatus: status));
        expect(find.text('Leave a review'), findsNothing);
      });
    }

    for (final status in ['completed', 'final_delivered']) {
      testWidgets('once the gig is $status and not yet reviewed', (tester) async {
        await _pumpBooking(tester, _Backend(gigStatus: status));
        expect(find.text('Leave a review'), findsOneWidget);
      });
    }

    testWidgets("not for someone else's booking - the server refuses it outright", (tester) async {
      await _pumpBooking(tester, _Backend(bookingStatusCode: 403));
      expect(find.text('Leave a review'), findsNothing);
    });
  });

  group('once reviewed', () {
    testWidgets('shows the review and never offers the form again', (tester) async {
      final backend = _Backend()..review = null;
      backend.review = backend.reviewJson(rating: 4, text: 'Lovely afternoon', wouldBookAgain: true);
      await _pumpBooking(tester, backend);

      expect(find.text('Your review'), findsOneWidget);
      expect(find.text('Lovely afternoon'), findsOneWidget);
      expect(find.text('Leave a review'), findsNothing, reason: 'write-once: a second review is refused');
    });

    testWidgets("shows the photographer's reply", (tester) async {
      final backend = _Backend();
      backend.review = backend.reviewJson(rating: 5, wouldBookAgain: true, reply: 'Thank you!');
      await _pumpBooking(tester, backend);
      expect(find.text('Thank you!'), findsOneWidget);
    });

    testWidgets('a review a moderator hid is still yours, and says it is not public', (tester) async {
      final backend = _Backend();
      backend.review = backend.reviewJson(rating: 2, text: 'Meh', wouldBookAgain: false, status: 'hidden');
      await _pumpBooking(tester, backend);

      expect(find.text('Your review'), findsOneWidget);
      expect(find.textContaining('not shown publicly'), findsOneWidget);
      expect(find.text('Leave a review'), findsNothing);
    });
  });

  group('writing one', () {
    Future<void> openForm(WidgetTester tester) async {
      await tester.tap(find.text('Leave a review'));
      await tester.pumpAndSettle();
    }

    Future<void> answer(WidgetTester tester, {int stars = 4, bool again = true, String? text}) async {
      await tester.tap(find.byTooltip('$stars stars'));
      await tester.tap(find.widgetWithText(InkWell, again ? 'Yes' : 'No'));
      if (text != null) await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    Finder post() => find.widgetWithText(ElevatedButton, 'Post review');

    testWidgets('cannot be posted until a rating and "would book again" are both answered', (tester) async {
      await _pumpBooking(tester, _Backend());
      await openForm(tester);

      expect(tester.widget<ElevatedButton>(post()).onPressed, isNull, reason: 'nothing answered');
      await tester.tap(find.byTooltip('5 stars'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(post()).onPressed, isNull, reason: 'would-book-again has no default');
      await tester.tap(find.widgetWithText(InkWell, 'No'));
      await tester.pump();
      expect(tester.widget<ElevatedButton>(post()).onPressed, isNotNull);
    });

    testWidgets('sends exactly what was answered - no tags, no invented default', (tester) async {
      final backend = _Backend();
      await _pumpBooking(tester, backend);
      await openForm(tester);
      await answer(tester, stars: 3, again: false, text: '  Good light, late start  ');
      await tester.tap(post());
      await tester.pumpAndSettle();

      expect(backend.posted, hasLength(1));
      final body = backend.posted.single;
      expect(body['rating'], 3);
      expect(body['would_book_again'], isFalse, reason: 'the API defaults this to true - it must be sent');
      expect(body['text'], 'Good light, late start');
      expect(body['tags'] ?? const <Object>[], isEmpty);
      expect(body['video_media_asset_id'], isNull);
    });

    testWidgets('"your review" appears because the server has it, not because we sent it', (tester) async {
      final backend = _Backend();
      await _pumpBooking(tester, backend);
      await openForm(tester);
      await answer(tester, text: 'Wonderful');
      await tester.tap(post());
      await tester.pumpAndSettle();

      expect(find.text('Your review'), findsOneWidget);
      expect(find.text('Wonderful'), findsOneWidget);
      expect(find.text('Leave a review'), findsNothing);
    });

    testWidgets('already reviewed elsewhere: says so, and shows that review', (tester) async {
      final backend = _Backend()
        ..refuseReview = (status: 409, code: 'already_exists', message: 'A review already exists for this gig');
      await _pumpBooking(tester, backend);
      await openForm(tester);
      await answer(tester);
      // The review the server already holds, which the refetch must surface.
      backend.review = backend.reviewJson(rating: 5, text: 'From my other phone', wouldBookAgain: true);
      await tester.tap(post());
      await tester.pumpAndSettle();

      expect(find.text("You've already reviewed this booking."), findsOneWidget);
      expect(find.text('From my other phone'), findsOneWidget);
      expect(find.text('Leave a review'), findsNothing);
    });

    for (final (label, status, code, expected) in [
      ('not reviewable yet', 409, 'invalid_state', "This booking can't be reviewed yet."),
      ('too long for the server', 422, 'validation_error', 'Review text too long'),
      ('rate limited', 429, 'rate_limited', "You've left a lot of reviews today. Try again tomorrow."),
      ('server error', 500, 'internal_error', "Couldn't send your review. Try again."),
    ]) {
      testWidgets('a refusal is shown, never swallowed: $label', (tester) async {
        final backend = _Backend()..refuseReview = (status: status, code: code, message: 'Review text too long');
        await _pumpBooking(tester, backend);
        await openForm(tester);
        await answer(tester, text: 'Kept');
        await tester.tap(post());
        await tester.pumpAndSettle();

        expect(find.text(expected), findsOneWidget);
        expect(find.text('Your review'), findsNothing, reason: 'nothing was saved, so nothing is shown as saved');
        expect(find.text('Kept'), findsOneWidget, reason: 'their words stay in the box to try again');
      });
    }

    testWidgets('too long is caught before sending, with the words kept', (tester) async {
      final backend = _Backend();
      await _pumpBooking(tester, backend);
      await openForm(tester);
      await answer(tester, text: 'x' * 2001);
      await tester.tap(post());
      await tester.pumpAndSettle();

      expect(find.text('Keep it under 2,000 characters.'), findsOneWidget);
      expect(backend.posted, isEmpty);
    });
  });

  testWidgets("a posted review appears on the photographer's profile", (tester) async {
    final backend = _Backend();
    await _pumpBooking(tester, backend);
    await tester.tap(find.text('Leave a review'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('5 stars'));
    await tester.tap(find.widgetWithText(InkWell, 'Yes'));
    await tester.enterText(find.byType(TextField), 'Best wedding photos we could have asked for');
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post review'));
    await tester.pumpAndSettle();

    // Now as anyone reading the profile. The reviews come from the public
    // list - the same backend state the submission changed. A fresh app, not
    // the booking screen's providers.
    await tester.pumpWidget(const SizedBox());
    final dio = backend.dio();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewsClientProvider.overrideWithValue(ReviewsClient(dio)),
          proProfileProvider(_proId).overrideWith((ref) async => _profile(reviewCount: 1)),
        ],
        child: MaterialApp(theme: buildClientTheme(), home: const ProProfileScreen(proUserId: _proId)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Best wedding photos we could have asked for'), 200);

    expect(find.text('Best wedding photos we could have asked for'), findsOneWidget);
    expect(find.textContaining('Verified booking · Weddings'), findsOneWidget);
    expect(find.textContaining('client-1'), findsNothing, reason: 'nothing identifies the client');
  });

  testWidgets('a profile with no reviews says so, rather than drawing an empty list', (tester) async {
    final dio = _Backend().dio();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewsClientProvider.overrideWithValue(ReviewsClient(dio)),
          proProfileProvider(_proId).overrideWith((ref) async => _profile(reviewCount: 0)),
        ],
        child: MaterialApp(theme: buildClientTheme(), home: const ProProfileScreen(proUserId: _proId)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reviews'), findsNothing);
  });
}

ClientProProfileResponse _profile({required int reviewCount}) => ClientProProfileResponse(
      proUserId: _proId,
      displayName: 'Bea',
      avgRating: reviewCount == 0 ? '0.00' : '5.00',
      reviewCount: reviewCount,
      portfolioPhotoCount: 0,
      portfolioVideoCount: 0,
      isGuestView: false,
    );
