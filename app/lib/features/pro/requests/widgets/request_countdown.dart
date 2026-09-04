import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Ticks down the response deadline on a pending booking request.
///
/// Seeded from the server's `secondsUntilExpiry`, never recomputed from
/// `expiresAt` against the device clock. That is the whole reason the server
/// sends a duration rather than only a timestamp: a phone with a skewed clock
/// would otherwise misreport the one deadline the product actually enforces.
/// Only the *elapsed* time since the screen loaded is measured locally, which
/// a wrong wall clock cannot distort.
///
/// On reaching zero this calls [onExpired] rather than rendering "expired".
/// The server sweeps expired requests every 15 minutes, so there is a window
/// where the deadline has passed but the request is still acceptable. Showing
/// a closed door that is in fact open would cost the photographer a booking;
/// asking the server means what's on screen is what will be enforced.
class RequestCountdown extends StatefulWidget {
  const RequestCountdown({required this.secondsUntilExpiry, required this.onExpired, super.key});

  final int secondsUntilExpiry;
  final VoidCallback onExpired;

  @override
  State<RequestCountdown> createState() => _RequestCountdownState();
}

class _RequestCountdownState extends State<RequestCountdown> {
  Timer? _timer;
  late int _remaining;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.secondsUntilExpiry;
    _start();
  }

  @override
  void didUpdateWidget(RequestCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A refresh delivered a new server value - re-seed rather than keep
    // counting from the stale one.
    if (oldWidget.secondsUntilExpiry != widget.secondsUntilExpiry) {
      _remaining = widget.secondsUntilExpiry;
      _notified = false;
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    if (_remaining <= 0) {
      _notifyExpired();
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        _timer?.cancel();
        _notifyExpired();
      }
    });
  }

  void _notifyExpired() {
    if (_notified) return;
    _notified = true;
    // Deferred: this can fire from initState, and refetching mid-build would
    // mutate a provider while the tree is being built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onExpired();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_remaining <= 0) {
      // Transient: onExpired has already asked the server what's true.
      return Text('Checking…', style: theme.textTheme.bodySmall);
    }

    final urgent = _remaining < const Duration(hours: 6).inSeconds;
    return Text(
      '${_format(_remaining)} to respond',
      style: theme.textTheme.bodySmall?.copyWith(
        color: urgent ? theme.colorScheme.error : null,
        fontFeatures: RType.tabularFigures,
      ),
    );
  }
}

/// Coarse near the deadline is useless - "2h" when 5 minutes remain would be
/// a lie - so the unit tightens as the deadline approaches.
String _format(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  if (duration.inHours >= 1) {
    final minutes = duration.inMinutes.remainder(60);
    return '${duration.inHours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (duration.inMinutes >= 1) {
    final seconds = duration.inSeconds.remainder(60);
    return '${duration.inMinutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  return '${duration.inSeconds}s';
}
