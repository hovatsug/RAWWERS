// "Meet the photographer", the photographer's side: write, preview exactly what
// clients will read, publish. Lengths and the contact-details warning are the
// server's; a warning never stops anything.
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/api_client/meet_client.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/interview/interview_screen.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';

import '../../support/fake_http_client_adapter.dart';

class _Profile extends ProProfileController {
  @override
  Future<ProProfileView> build() async =>
      const ProProfileView(userId: 'pro-me', displayName: 'Ana', isAcceptingBookings: true, completenessScore: 90, kycStatus: 'approved');
}

class _Backend {
  _Backend({this.warning, this.published = false});

  final String? warning;
  bool published;
  final drafts = <String, String?>{'q-who': null, 'q-style': null};
  final saves = <Map<String, dynamic>>[];
  int publishes = 0;
  int unpublishes = 0;

  Map<String, dynamic> _view() => {
        'items': [
          {
            'question_id': 'q-who', 'prompt': 'Who are you, what do you shoot, and where?', 'title': 'Who I am',
            'hint': 'One or two sentences.', 'min_chars': 20, 'max_chars': 200, 'draft': drafts['q-who'],
            'published': published ? drafts['q-who'] : null, 'warning': drafts['q-who'] == null ? null : warning,
          },
          {
            'question_id': 'q-style', 'prompt': 'How do your photos look and feel?', 'title': 'My style', 'hint': null,
            'min_chars': 30, 'max_chars': 300, 'draft': drafts['q-style'], 'published': null, 'warning': null,
          },
        ],
        'is_published': published,
        'published_at': null,
        'has_unpublished_changes': false,
      };

  Future<ResponseBody> handle(RequestOptions o) async {
    final path = o.uri.path;
    if (path == '/v1/pro/me/interview' && o.method == 'GET') return jsonResponseBody(jsonEncode(_view()), 200);
    if (path == '/v1/pro/me/interview' && o.method == 'PUT') {
      final body = (o.data is String ? jsonDecode(o.data as String) : o.data) as Map<String, dynamic>;
      saves.add(body);
      (body['answers'] as Map<String, dynamic>).forEach((k, v) => drafts[k] = v as String?);
      return jsonResponseBody(jsonEncode(_view()), 200);
    }
    if (path == '/v1/pro/me/interview/publish') {
      publishes++;
      published = true;
      return jsonResponseBody(jsonEncode(_view()), 200);
    }
    if (path == '/v1/pro/me/interview/unpublish') {
      unpublishes++;
      published = false;
      return jsonResponseBody(jsonEncode(_view()), 200);
    }
    return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
  }
}

Future<void> _pump(WidgetTester tester, _Backend backend) async {
  tester.view.physicalSize = const Size(1170, 4000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))..httpClientAdapter = FakeHttpClientAdapter(backend.handle);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        meetClientProvider.overrideWithValue(MeetClient(dio)),
        proProfileControllerProvider.overrideWith(_Profile.new),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const InterviewScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

const _who = "I'm Ana, a portrait photographer in Lisbon.";

void main() {
  testWidgets('each question shows what is asked, its hint and the title clients will read', (tester) async {
    await _pump(tester, _Backend());
    expect(find.text('Who are you, what do you shoot, and where?'), findsOneWidget);
    expect(find.text('One or two sentences.'), findsOneWidget);
    expect(find.text('Clients see this as “Who I am”'), findsOneWidget);
    expect(find.text('Not on your profile yet.'), findsOneWidget);
  });

  testWidgets('the limit comes from the server and a short answer says what publishing needs', (tester) async {
    await _pump(tester, _Backend());
    final field = tester.widget<TextField>(find.byType(TextField).first);
    expect(field.maxLength, 200);
    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.pump();
    expect(find.text('At least 20 characters to publish'), findsOneWidget);
  });

  testWidgets('saving a draft sends every answer, empty ones as nothing', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);
    await tester.enterText(find.byType(TextField).first, '  $_who  ');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(backend.saves.single['answers'], {'q-who': _who, 'q-style': null});
  });

  testWidgets('a contact-details warning shows, and nothing is stopped', (tester) async {
    final backend = _Backend(warning: 'This looks like contact details (an email address).');
    await _pump(tester, backend);
    await tester.enterText(find.byType(TextField).first, 'Write to ana@example.com, I shoot portraits.');
    await tester.tap(find.text('Save draft'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('contact-warning-q-who')), findsOneWidget);

    await tester.tap(find.text('Preview and publish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    expect(backend.publishes, 1, reason: 'a warning must never block publishing');
  });

  testWidgets('the preview is the client\'s own section, and publishing waits for it', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);
    await tester.enterText(find.byType(TextField).first, _who);
    await tester.tap(find.text('Preview and publish'));
    await tester.pumpAndSettle();

    expect(find.byType(MeetSection), findsOneWidget);
    expect(find.text('Meet Ana'), findsOneWidget);
    expect(find.text(_who), findsOneWidget);
    expect(find.text('My style'), findsNothing, reason: 'an unanswered question is not shown');
    expect(backend.publishes, 0, reason: 'nothing published before they choose to');

    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    expect(backend.publishes, 1);
    expect(find.text('On your profile.'), findsOneWidget);
  });

  testWidgets('keep editing publishes nothing', (tester) async {
    final backend = _Backend();
    await _pump(tester, backend);
    await tester.enterText(find.byType(TextField).first, _who);
    await tester.tap(find.text('Preview and publish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(backend.publishes, 0);
  });

  testWidgets('an unpublished interview has nothing to remove', (tester) async {
    await _pump(tester, _Backend());
    expect(find.text('Remove from my profile'), findsNothing);
  });

  testWidgets('a published interview can be removed from the profile', (tester) async {
    final backend = _Backend(published: true)..drafts['q-who'] = _who;
    await _pump(tester, backend);
    await tester.tap(find.text('Remove from my profile'));
    await tester.pumpAndSettle();
    expect(backend.unpublishes, 1);
  });
}
