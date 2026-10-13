// The Requests tab's badge: how a photographer with the app open learns a
// request arrived, with no push yet. A short-notice request has 30 minutes
// to be answered, so the badge polls, and it counts from the same pending
// list the tab shows.
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/pro_onboarding_client.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';

import '../../support/fake_http_client_adapter.dart';

class _Backend {
  /// Expiry offsets from now, one per pending request.
  List<Duration> pending = [];
  String? nextCursor;
  int listFetches = 0;

  Map<String, dynamic> _item(int i, Duration expiresIn) => {
        'id': 'req-$i',
        'pro_user_id': 'pro-me',
        'client_user_id': 'client-$i',
        'package_id': 'pkg-1',
        'requested_start': '2026-10-14T10:00:00Z',
        'requested_end': '2026-10-14T11:00:00Z',
        'status': 'pending',
        'expires_at': DateTime.now().add(expiresIn).toUtc().toIso8601String(),
        'created_at': '2026-10-13T09:00:00Z',
      };

  Future<ResponseBody> handle(RequestOptions o) async {
    if (o.uri.path == '/v1/booking-requests' && o.method == 'GET') {
      listFetches++;
      return jsonResponseBody(
        jsonEncode({
          'items': [for (var i = 0; i < pending.length; i++) _item(i, pending[i])],
          'next_cursor': nextCursor,
        }),
        200,
      );
    }
    if (RegExp(r'^/v1/booking-requests/[^/]+/accept$').hasMatch(o.uri.path)) {
      final accepted = {..._item(0, pending.first), 'status': 'accepted'};
      pending = pending.sublist(1);
      return jsonResponseBody(
        jsonEncode({
          'booking_request': accepted,
          'gig_id': 'gig-1',
          'payment_intent_id': 'pi_1',
          'payment_intent_client_secret': 'pi_1_secret',
        }),
        200,
      );
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

Future<ProviderContainer> _pumpBadge(WidgetTester tester, _Backend backend) async {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  final container = ProviderContainer(overrides: [proOnboardingClientProvider.overrideWithValue(ProOnboardingClient(dio))]);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: RequestsTabIcon(Icons.inbox))),
    ),
  );
  await _settle(tester);
  return container;
}

/// Lets the fake backend answer: a few frames, short of the next poll.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 10));
  }
}

/// The badge's poll is kept alive for the app's life; a test ends it.
Future<void> _end(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(const SizedBox.shrink());
  container.dispose();
}

String? _badge(WidgetTester tester) {
  final badge = tester.widget<Badge>(find.byType(Badge));
  return badge.isLabelVisible ? (badge.label! as Text).data : null;
}

void main() {
  testWidgets('counts the requests still waiting, not one past its deadline the sweep has not reached', (tester) async {
    final backend = _Backend()
      ..pending = [const Duration(minutes: 25), const Duration(hours: 20), const Duration(minutes: -2)];
    final container = await _pumpBadge(tester, backend);

    expect(_badge(tester), '2');
    await _end(tester, container);
  });

  testWidgets('says "+" when there is more than one page', (tester) async {
    final backend = _Backend()
      ..pending = [const Duration(minutes: 25)]
      ..nextCursor = 'next';
    final container = await _pumpBadge(tester, backend);

    expect(_badge(tester), '1+');
    await _end(tester, container);
  });

  testWidgets('nothing waiting shows no badge', (tester) async {
    final container = await _pumpBadge(tester, _Backend());

    expect(_badge(tester), isNull);
    await _end(tester, container);
  });

  testWidgets('a request that arrives shows within 30 seconds, and the list is refetched for it', (tester) async {
    final backend = _Backend();
    final container = await _pumpBadge(tester, backend);
    // The tab's list, as if the photographer had it open.
    final listening = container.listen(requestsControllerProvider, (_, _) {});
    await _settle(tester);
    final listFetchesBefore = backend.listFetches;

    backend.pending = [const Duration(minutes: 30)];
    await tester.pump(PendingRequestsController.pollEvery);
    await _settle(tester);

    expect(_badge(tester), '1');
    // One for the badge's own poll, one for the list it refreshed.
    expect(backend.listFetches - listFetchesBefore, 2);
    listening.close();
    await _end(tester, container);
  });

  testWidgets('answering a request updates the badge at once, not at the next poll', (tester) async {
    final backend = _Backend()..pending = [const Duration(minutes: 25), const Duration(minutes: 25)];
    final container = await _pumpBadge(tester, backend);
    expect(_badge(tester), '2');

    final listening = container.listen(requestsControllerProvider, (_, _) {});
    await _settle(tester);
    // Started, not awaited: under the test clock it completes as frames pass.
    unawaited(container.read(requestsControllerProvider.notifier).accept('req-0'));
    await _settle(tester);

    expect(_badge(tester), '1');
    listening.close();
    await _end(tester, container);
  });
}
