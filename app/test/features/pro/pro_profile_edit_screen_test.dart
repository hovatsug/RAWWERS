import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/profile/pro_profile_edit_screen.dart';
import 'package:rawwers/features/pro/profile/profile_editor_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';

class _FakeProfile extends ProProfileController {
  _FakeProfile(this._profile);

  final ProProfileView _profile;

  @override
  Future<ProProfileView> build() async => _profile;
}

class _RecordingEditor extends ProfileEditorController {
  int? sentRadius;
  List<String>? sentStyles;
  String? sentHeadline;
  var saveCount = 0;

  @override
  Future<void> build() async {}

  @override
  Future<String?> save({
    required ProProfileView current,
    String? displayName,
    String? headline,
    String? bio,
    String? city,
    String? country,
    int? travelRadiusKm,
    List<String>? languages,
    List<String>? styles,
  }) async {
    saveCount++;
    sentRadius = travelRadiusKm;
    sentStyles = styles;
    sentHeadline = headline;
    return null;
  }
}

ProProfileView _profile({int? travelRadiusKm, List<String>? styles}) => ProProfileView(
      userId: 'pro-1',
      displayName: 'Alex Lens',
      headline: 'Portraits in daylight',
      city: 'Lisbon',
      country: 'PT',
      travelRadiusKm: travelRadiusKm,
      styles: styles,
      isAcceptingBookings: true,
      completenessScore: 90,
      kycStatus: 'approved',
    );

Widget _wrap(ProProfileView profile, _RecordingEditor editor) => ProviderScope(
      overrides: [
        proProfileControllerProvider.overrideWith(() => _FakeProfile(profile)),
        profileEditorControllerProvider.overrideWith(() => editor),
      ],
      child: MaterialApp(theme: buildProTheme(), home: const ProProfileEditScreen()),
    );

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(target, 200, scrollable: find.byType(Scrollable).first);
  await tester.pump();
}

/// Fields are found by their label rather than by position: a form whose
/// tests depend on field order breaks every time a field is added, which
/// teaches you to stop trusting the failures.
Finder _fieldNamed(String label) => find.descendant(
      of: find.byWidgetPredicate((w) => w is RInput && w.label == label),
      matching: find.byType(TextField),
    );

void main() {
  testWidgets('an unanswered travel radius shows empty, not zero', (tester) async {
    // "Will not travel" and "has not said" are different answers, and
    // prefilling a 0 would answer on the photographer's behalf.
    await tester.pumpWidget(_wrap(_profile(), _RecordingEditor()));
    await tester.pump();

    await _scrollTo(tester, find.text('Travel radius (km)'));
    final field = tester.widget<TextField>(_fieldNamed('Travel radius (km)'));
    expect(field.controller!.text, isEmpty);
  });

  testWidgets('a travel radius that is not a number is refused before sending', (tester) async {
    final editor = _RecordingEditor();
    await tester.pumpWidget(_wrap(_profile(), editor));
    await tester.pump();

    await _scrollTo(tester, find.text('Travel radius (km)'));
    await tester.enterText(_fieldNamed('Travel radius (km)'), 'quite far');
    await _scrollTo(tester, find.widgetWithText(RButton, 'Save'));
    await tester.tap(find.widgetWithText(RButton, 'Save'));
    await tester.pump();

    expect(editor.saveCount, 0);
    expect(find.textContaining('number of kilometres'), findsOneWidget);
  });

  testWidgets('styles are picked from a list, not typed', (tester) async {
    // A client filtering on "Editorial" finds nobody who typed "editorial ".
    final editor = _RecordingEditor();
    await tester.pumpWidget(_wrap(_profile(styles: const ['Editorial']), editor));
    await tester.pump();

    await _scrollTo(tester, find.text('Documentary'));
    await tester.tap(find.text('Documentary'));
    await tester.pump();

    await _scrollTo(tester, find.widgetWithText(RButton, 'Save'));
    await tester.tap(find.widgetWithText(RButton, 'Save'));
    await tester.pump();

    expect(editor.sentStyles, containsAll(<String>['Editorial', 'Documentary']));
  });

  testWidgets('a failed load says so rather than showing an empty form', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proProfileControllerProvider.overrideWith(_FailingProfile.new),
          profileEditorControllerProvider.overrideWith(_RecordingEditor.new),
        ],
        child: MaterialApp(theme: buildProTheme(), home: const ProProfileEditScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Could not load your profile.'), findsOneWidget);
  });
}

class _FailingProfile extends ProProfileController {
  @override
  Future<ProProfileView> build() async => throw Exception('boom');
}
