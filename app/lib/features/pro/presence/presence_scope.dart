import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/pro/presence/presence_heartbeat.dart';

/// Builds the heartbeat for the signed-in photographer. A provider so a test
/// can hand the scope a heartbeat talking to a fake server.
final presenceHeartbeatFactoryProvider = Provider<PresenceHeartbeat Function()>((ref) {
  final client = ref.watch(presenceClientProvider);
  Future<void> ok<T>(Future<Result<T>> call) async {
    if (await call case Err(:final failure)) throw failure;
  }

  return () => PresenceHeartbeat(
        beat: () => ok(apiCall(() => client.heartbeatV1ProPresenceHeartbeatPost(authorization: null, xMinusUserMinusId: null))),
        clear: () => ok(apiCall(() => client.goOfflineV1ProPresenceDelete(authorization: null, xMinusUserMinusId: null))),
      );
});

/// Keeps the photographer online while the app is in the foreground.
///
/// Wraps the signed-in pro app, so it runs only for a signed-in photographer
/// and stops when they sign out (the scope is disposed - and since signing
/// out is not going to the background, it also clears).
class PresenceScope extends ConsumerStatefulWidget {
  const PresenceScope({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PresenceScope> createState() => _PresenceScopeState();
}

class _PresenceScopeState extends ConsumerState<PresenceScope> {
  late final PresenceHeartbeat _heartbeat;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _heartbeat = ref.read(presenceHeartbeatFactoryProvider)();
    _lifecycle = AppLifecycleListener(
      onResume: _heartbeat.resume,
      // Hidden is the first sign of leaving on every platform; paused may not
      // follow on iOS before the app is suspended.
      onHide: _heartbeat.pause,
    );
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) _heartbeat.resume();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _heartbeat.pause();
    _heartbeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
