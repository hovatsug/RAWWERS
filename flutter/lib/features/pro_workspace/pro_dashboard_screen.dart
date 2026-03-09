import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import 'widgets.dart';

class ProDashboardScreen extends ConsumerStatefulWidget {
  const ProDashboardScreen({super.key});

  @override
  ConsumerState<ProDashboardScreen> createState() => _ProDashboardScreenState();
}

class _ProDashboardScreenState extends ConsumerState<ProDashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _checks = {};
  Map<String, dynamic> _balance = {};
  int _threadsCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = ref.read(proApiProvider);
    final checks = await api.getOnboardingChecks();
    final balance = await api.getEarningsBalance();
    final threads = await api.listProThreads({'limit': 5});

    if (!mounted) return;

    if (!checks.ok || !balance.ok || !threads.ok) {
      setState(() {
        _loading = false;
        _error = checks.error?.message ?? balance.error?.message ?? threads.error?.message ?? 'Failed to load dashboard';
      });
      return;
    }

    final threadItems = (threads.data?['items'] as List<dynamic>?) ?? const [];

    setState(() {
      _checks = checks.data ?? {};
      _balance = balance.data ?? {};
      _threadsCount = threadItems.length;
      _loading = false;
    });

    await api.track('pro_dashboard_viewed', {'source': 'flutter'});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(
        children: [
          RSkeleton(height: 90),
          SizedBox(height: RTokens.spacingX3),
          RSkeleton(height: 90),
          SizedBox(height: RTokens.spacingX3),
          RSkeleton(height: 90),
        ],
      );
    }
    if (_error != null) {
      return ProErrorState(message: _error!, onRetry: _load);
    }

    final pending = _checks.values.where((value) => value == false).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dashboard', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pending checks', style: TextStyle(color: RTokens.neutralMuted)),
              const SizedBox(height: RTokens.spacingX1),
              Text('$pending', style: const TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: RTokens.spacingX3),
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Earnings balance', style: TextStyle(color: RTokens.neutralMuted)),
              const SizedBox(height: RTokens.spacingX1),
              Text('${_balance['available_balance'] ?? _balance['available'] ?? '-'}', style: const TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: RTokens.spacingX3),
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent threads', style: TextStyle(color: RTokens.neutralMuted)),
              const SizedBox(height: RTokens.spacingX1),
              Text('$_threadsCount', style: const TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}
