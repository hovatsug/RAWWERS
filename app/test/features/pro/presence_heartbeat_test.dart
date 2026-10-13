import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/pro/presence/presence_heartbeat.dart';

/// A server for the heartbeat to talk to: counts calls, and can be told to
/// fail or to hang.
class _FakeServer {
  int beats = 0;
  int clears = 0;
  bool failing = false;
  bool hanging = false;

  Future<void> beat() {
    if (hanging) return Completer<void>().future; // never completes
    if (failing) return Future.error(Exception('503'));
    beats++;
    return Future.value();
  }

  Future<void> clear() async => clears++;
}

PresenceHeartbeat _heartbeat(_FakeServer server) => PresenceHeartbeat(beat: server.beat, clear: server.clear);

void main() {
  // testWidgets runs on a fake clock: pump(duration) moves time on.
  testWidgets('in the foreground it beats at once and then once a minute', (tester) async {
    final server = _FakeServer();
    final heartbeat = _heartbeat(server)..resume();
    await tester.pump();
    expect(server.beats, 1);

    await tester.pump(const Duration(seconds: 59));
    expect(server.beats, 1, reason: 'not before the minute');
    await tester.pump(const Duration(seconds: 1));
    expect(server.beats, 2);
    await tester.pump(const Duration(minutes: 3));
    expect(server.beats, 5);
    heartbeat.dispose();
  });

  testWidgets('going to the background stops the heartbeat and sends one clear', (tester) async {
    final server = _FakeServer();
    final heartbeat = _heartbeat(server)..resume();
    await tester.pump();

    heartbeat.pause();
    heartbeat.pause(); // a second pause event sends nothing more
    await tester.pump(const Duration(minutes: 5));

    expect(server.clears, 1);
    expect(server.beats, 1, reason: 'nothing while in the background');
  });

  testWidgets('coming back beats at once and resumes the pace', (tester) async {
    final server = _FakeServer();
    final heartbeat = _heartbeat(server)..resume();
    await tester.pump();
    heartbeat.pause();
    await tester.pump(const Duration(minutes: 10));

    heartbeat.resume();
    await tester.pump();
    expect(server.beats, 2);
    await tester.pump(const Duration(minutes: 1));
    expect(server.beats, 3);
    heartbeat.dispose();
  });

  testWidgets('a failing server backs off, never claims success, and recovers', (tester) async {
    final server = _FakeServer()..failing = true;
    final heartbeat = _heartbeat(server)..resume();
    await tester.pump();
    expect(heartbeat.lastBeatSucceeded, isFalse);

    // 10s, 20s, 40s, then capped at the minute.
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 20));
    await tester.pump(const Duration(seconds: 40));
    expect(heartbeat.consecutiveFailures, 4);
    expect(heartbeat.lastBeatSucceeded, isFalse, reason: 'no false online while it fails');
    expect(server.beats, 0);

    server.failing = false;
    await tester.pump(const Duration(seconds: 60));
    expect(server.beats, 1);
    expect(heartbeat.lastBeatSucceeded, isTrue);
    expect(heartbeat.consecutiveFailures, 0);
    await tester.pump(const Duration(seconds: 60));
    expect(server.beats, 2, reason: 'back to the normal pace');
    heartbeat.dispose();
  });

  testWidgets('a hung call times out, is not stacked, and the next one gets through', (tester) async {
    final server = _FakeServer()..hanging = true;
    final heartbeat = _heartbeat(server)..resume();
    await tester.pump(const Duration(seconds: 5));
    expect(heartbeat.lastBeatSucceeded, isFalse);

    await tester.pump(const Duration(seconds: 5)); // the 10s timeout
    expect(heartbeat.consecutiveFailures, 1);

    server.hanging = false;
    await tester.pump(const Duration(seconds: 10)); // the first retry
    expect(server.beats, 1);
    expect(heartbeat.lastBeatSucceeded, isTrue);
    heartbeat.dispose();
  });

  testWidgets('a background clear that fails is not retried and does not throw', (tester) async {
    final heartbeat = PresenceHeartbeat(beat: () async {}, clear: () => Future.error(Exception('offline')))..resume();
    await tester.pump();

    heartbeat.pause();
    await tester.pump(const Duration(seconds: 30));

    expect(heartbeat.isRunning, isFalse);
  });
}
