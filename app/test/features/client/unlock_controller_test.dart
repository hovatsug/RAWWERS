// The review gate's two ways through, against a fake server: what is sent,
// and that an answer the server already holds counts as unlocked.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/proof_galleries_client.dart';
import 'package:rawwers/api/api_client/reviews_client.dart';
import 'package:rawwers/api/models/problem_report_reason.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';
import 'package:rawwers/features/client/gallery/unlock_controller.dart';

import '../../support/fake_http_client_adapter.dart';

class _Server {
  final bodies = <String, Map<String, dynamic>>{};
  int status = 200;
  Map<String, dynamic> error = const {};

  Future<ResponseBody> handle(RequestOptions o) async {
    // As it goes on the wire.
    bodies[o.uri.path] = Map<String, dynamic>.from(jsonDecode(jsonEncode(o.data)) as Map);
    if (status != 200) return jsonResponseBody(jsonEncode({'error': error}), status);
    if (o.uri.path.endsWith('/review')) {
      return jsonResponseBody(
        jsonEncode({
          'id': 'r1', 'gig_id': 'gig-1', 'pro_user_id': 'p', 'client_user_id': 'c', 'niche_id': 'n',
          'rating': bodies[o.uri.path]!['rating'], 'tags': <String>[], 'would_book_again': bodies[o.uri.path]!['would_book_again'],
          'status': 'published', 'created_at': '2026-11-01T12:00:00Z', 'updated_at': '2026-11-01T12:00:00Z',
        }),
        200,
      );
    }
    return jsonResponseBody(
      jsonEncode({'id': 'pr1', 'gig_id': 'gig-1', ...bodies[o.uri.path]!, 'created_at': '2026-11-01T12:00:00Z'}),
      200,
    );
  }
}

class _CountingDelivered extends DeliveredController {
  _CountingDelivered(this.builds);
  final List<int> builds;

  @override
  Future<DeliveredState> build(String galleryId) async {
    builds.add(1);
    return const DeliveredState.locked(gigId: 'gig-1');
  }
}

(ProviderContainer, _Server, List<int>) _container() {
  final server = _Server();
  final builds = <int>[];
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(server.handle);
  final container = ProviderContainer(overrides: [
    reviewsClientProvider.overrideWithValue(ReviewsClient(dio)),
    deliveredControllerProvider('g1').overrideWith(() => _CountingDelivered(builds)),
  ]);
  addTearDown(container.dispose);
  return (container, server, builds);
}

void main() {
  group('the delivered gallery behind the gate', _deliveredTests);

  test('a star is a rating with nothing else, and the gallery reloads', () async {
    final (container, server, builds) = _container();
    // Listened to, as the screen does, so it is built again only when asked.
    container.listen(deliveredControllerProvider('g1'), (_, _) {});
    await container.read(deliveredControllerProvider('g1').future);

    final problem = await container.read(unlockControllerProvider('g1').notifier).rate(gigId: 'gig-1', stars: 2);
    await container.read(deliveredControllerProvider('g1').future);

    expect(problem, isNull);
    final sent = server.bodies['/v1/gigs/gig-1/review']!;
    expect(sent['rating'], 2);
    expect(sent['text'], isNull);
    // One tap does not ask; 1-3 stars is not "would book again".
    expect(sent['would_book_again'], isFalse);
    expect(builds, hasLength(2), reason: 'the gallery was asked again, so the photos appear');
  });

  test('four stars or five count as "would book again"', () async {
    final (container, server, _) = _container();
    await container.read(unlockControllerProvider('g1').notifier).rate(gigId: 'gig-1', stars: 4);
    expect(server.bodies['/v1/gigs/gig-1/review']!['would_book_again'], isTrue);
  });

  test('a rating the server already holds is unlocked, not an error', () async {
    final (container, server, _) = _container();
    server
      ..status = 409
      ..error = {'code': 'already_exists', 'message': 'A review already exists for this gig'};
    expect(await container.read(unlockControllerProvider('g1').notifier).rate(gigId: 'gig-1', stars: 5), isNull);
  });

  test('a refusal comes back as the server said it', () async {
    final (container, server, _) = _container();
    server
      ..status = 409
      ..error = {'code': 'invalid_state', 'message': 'Gig is not reviewable yet'};
    expect(await container.read(unlockControllerProvider('g1').notifier).rate(gigId: 'gig-1', stars: 5), 'Gig is not reviewable yet');
  });

  test('a report sends the reason and the note, or no note when it is blank', () async {
    final (container, server, _) = _container();
    final unlock = container.read(unlockControllerProvider('g1').notifier);

    expect(await unlock.report(gigId: 'gig-1', reason: ProblemReportReason.wrongPhotos, note: '  '), isNull);
    expect(server.bodies['/v1/gigs/gig-1/problem-report'], {'reason': 'wrong_photos', 'note': null});

    await unlock.report(gigId: 'gig-1', reason: ProblemReportReason.other, note: ' Blurry ');
    expect(server.bodies['/v1/gigs/gig-1/problem-report']!['note'], 'Blurry');
  });
}

/// The real delivered controller against a fake server whose downloads
/// answer is the review gate's 403.
Future<DeliveredState> _deliveredAgainst(int downloadsStatus, Object downloadsBody) async {
  Future<ResponseBody> handle(RequestOptions o) async {
    if (o.uri.path == '/v1/proof-galleries/g1') {
      return jsonResponseBody(
        jsonEncode({
          'gallery': {
            'id': 'g1', 'gig_id': 'gig-1', 'pro_user_id': 'p', 'client_user_id': 'c', 'included_photos': 20,
            'extra_photo_price': '4.80', 'currency': 'EUR', 'status': 'selection_submitted',
            'created_at': '2026-11-01T12:00:00Z', 'updated_at': '2026-11-01T12:00:00Z',
          },
          'items': [
            {'media_asset_id': 'a1', 'sort_order': 1, 'thumbnail_url': 't1'},
          ],
        }),
        200,
      );
    }
    return jsonResponseBody(jsonEncode(downloadsBody), downloadsStatus);
  }

  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(handle);
  final container = ProviderContainer(overrides: [proofGalleriesClientProvider.overrideWithValue(ProofGalleriesClient(dio))]);
  addTearDown(container.dispose);
  return container.read(deliveredControllerProvider('g1').future);
}

void _deliveredTests() {
  test("the server's review gate becomes the locked state, with the booking to rate", () async {
    final state = await _deliveredAgainst(403, {
      'error': {'code': 'review_required', 'message': 'Rate your photographer to unlock your photos, or report a problem.'},
    });
    expect(state.locked, isTrue);
    expect(state.gigId, 'gig-1');
    expect(state.photos, isEmpty);
    expect(state.isEmpty, isFalse, reason: 'locked is not "nothing here yet"');
  });

  test('any other refusal is still an error', () async {
    await expectLater(
      _deliveredAgainst(403, {'error': {'code': 'forbidden', 'message': 'no'}}),
      throwsA(isA<Forbidden>()),
    );
  });

  test('unlocked, the photos come with their links', () async {
    final state = await _deliveredAgainst(200, {'gallery_id': 'g1', 'urls': {'a1': 'https://example.test/a1-original.jpg'}});
    expect(state.locked, isFalse);
    expect(state.photos.single.finalUrl, 'https://example.test/a1-original.jpg');
  });
}
