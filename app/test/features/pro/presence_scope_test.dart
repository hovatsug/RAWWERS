import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/pro/presence/presence_heartbeat.dart';
import 'package:rawwers/features/pro/presence/presence_scope.dart';

class _Counts {
  int beats = 0;
  int clears = 0;
}

Widget _app(_Counts counts) => ProviderScope(
      overrides: [
        presenceHeartbeatFactoryProvider.overrideWithValue(
          () => PresenceHeartbeat(beat: () async => counts.beats++, clear: () async => counts.clears++),
        ),
      ],
      child: const MaterialApp(home: PresenceScope(child: Scaffold(body: Text('pro app')))),
    );

void main() {
  testWidgets('the app lifecycle drives the heartbeat: away stops it with one clear, back restarts it', (tester) async {
    final counts = _Counts();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(_app(counts));
    await tester.pump();
    expect(counts.beats, 1, reason: 'opening the app beats at once');

    // Going to the background: resumed -> inactive -> hidden -> paused.
    for (final state in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump(const Duration(minutes: 3));
    expect(counts.clears, 1, reason: 'exactly one clear');
    expect(counts.beats, 1, reason: 'no heartbeat while away');

    for (final state in [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    expect(counts.beats, 2, reason: 'coming back beats at once');
    await tester.pump(const Duration(minutes: 1));
    expect(counts.beats, 3, reason: 'and keeps the pace');

    await tester.pumpWidget(const SizedBox()); // signed out: the scope goes
    await tester.pump(const Duration(minutes: 2));
    expect(counts.beats, 3);
    expect(counts.clears, 2, reason: 'leaving the signed-in app clears too');
  });

  testWidgets('a quick flick through inactive (control centre) does not drop presence', (tester) async {
    final counts = _Counts();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(_app(counts));
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(minutes: 1));

    expect(counts.clears, 0);
    expect(counts.beats, 2);
    await tester.pumpWidget(const SizedBox());
  });
}
