import 'dart:async';
import 'dart:math' as math;

/// Tells the server the photographer's app is open, while it is.
///
/// In the foreground: a heartbeat at once, then every [interval]. Going to
/// the background: the heartbeat stops and one clear is sent, so the dot goes
/// now rather than when the server's window runs out. If the clear never
/// arrives - force-quit, crash, no signal - the server's key expires on its
/// own (PRESENCE_WINDOW_SECONDS, 5 minutes). That expiry is the backstop;
/// nothing here has to be right for the dot to go eventually.
///
/// A failed or hung heartbeat never makes anyone look online: each call has
/// a [timeout], only one is ever in flight, and failures back off -
/// [retryAfter], doubling, capped at [interval] - then return to the normal
/// pace on the first success.
class PresenceHeartbeat {
  PresenceHeartbeat({
    required this.beat,
    required this.clear,
    this.interval = const Duration(seconds: 60),
    this.retryAfter = const Duration(seconds: 10),
    this.timeout = const Duration(seconds: 10),
  });

  /// One heartbeat. Throwing, or not completing within [timeout], is a failure.
  final Future<void> Function() beat;

  /// Going offline. Best effort.
  final Future<void> Function() clear;

  final Duration interval;
  final Duration retryAfter;
  final Duration timeout;

  Timer? _next;
  bool _running = false;
  bool _inFlight = false;
  int _failures = 0;

  /// Whether the last heartbeat got through - for display only, never a
  /// claim the server has not confirmed.
  bool get lastBeatSucceeded => _lastBeatSucceeded;
  bool _lastBeatSucceeded = false;

  int get consecutiveFailures => _failures;
  bool get isRunning => _running;

  /// The app came to the foreground (or started there).
  void resume() {
    if (_running) return;
    _running = true;
    _failures = 0;
    _send();
  }

  /// The app went to the background: stop, and clear once.
  void pause() {
    if (!_running) return;
    _running = false;
    _next?.cancel();
    _next = null;
    _lastBeatSucceeded = false;
    unawaited(clear().timeout(timeout).catchError((_) {}));
  }

  /// Signed out, or the screen holding this went away. Stops without a clear
  /// - the caller decides whether one is owed.
  void dispose() {
    _running = false;
    _next?.cancel();
    _next = null;
  }

  Future<void> _send() async {
    if (!_running || _inFlight) return;
    _inFlight = true;
    try {
      await beat().timeout(timeout);
      _failures = 0;
      _lastBeatSucceeded = true;
    } catch (_) {
      _failures++;
      _lastBeatSucceeded = false;
    } finally {
      _inFlight = false;
    }
    if (!_running) return;
    _next?.cancel();
    _next = Timer(_delayAfterLastAttempt(), _send);
  }

  Duration _delayAfterLastAttempt() {
    if (_failures == 0) return interval;
    final backoff = retryAfter * math.pow(2, _failures - 1).toInt();
    return backoff < interval ? backoff : interval;
  }
}
