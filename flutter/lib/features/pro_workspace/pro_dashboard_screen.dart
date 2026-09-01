import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_glass_card.dart';
import '../../design/widgets/r_glow_orbs.dart';
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
    return Stack(
      children: [
        const RGlowOrbs(variant: RGlowOrbsVariant.dashboard),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RSkeleton(height: 32, width: 180),
          SizedBox(height: RTokens.spacingX4),
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
    final availableBalance = '${_balance['available_balance'] ?? _balance['available'] ?? '—'}';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Welcome back. Here\'s what\'s happening.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: RTokens.spacingX6),

          // Stat cards
          _StatCard(
            label: 'Pending checks',
            value: '$pending',
            accentColor: RTokens.amber,
            glowColor: RTokens.glowAmber,
          ),
          const SizedBox(height: RTokens.spacingX3),
          _StatCard(
            label: 'Earnings balance',
            value: availableBalance,
            accentColor: RTokens.emerald,
            glowColor: RTokens.glowEmerald,
          ),
          const SizedBox(height: RTokens.spacingX3),
          _StatCard(
            label: 'Recent threads',
            value: '$_threadsCount',
            accentColor: RTokens.violetLight,
            glowColor: RTokens.glowVioletSm,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.glowColor,
  });

  final String label;
  final String value;
  final Color accentColor;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return RGlassCard(
      child: Stack(
        children: [
          // Inner accent orb
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: RTokens.textXs,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: RTokens.textSubtleDark,
                ),
              ),
              const SizedBox(height: RTokens.spacingX2),
              Text(
                value,
                style: TextStyle(
                  fontSize: RTokens.textX3l,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  shadows: [Shadow(color: glowColor, blurRadius: 20)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
