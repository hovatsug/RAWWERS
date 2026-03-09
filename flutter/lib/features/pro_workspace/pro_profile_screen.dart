import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import 'widgets.dart';

class ProProfileWorkspaceScreen extends ConsumerStatefulWidget {
  const ProProfileWorkspaceScreen({super.key});

  @override
  ConsumerState<ProProfileWorkspaceScreen> createState() => _ProProfileWorkspaceScreenState();
}

class _ProProfileWorkspaceScreenState extends ConsumerState<ProProfileWorkspaceScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _profile = {};

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
    final result = await ref.read(proApiProvider).getMyProProfile();
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Profile unavailable';
      });
      return;
    }

    setState(() {
      _loading = false;
      _profile = result.data ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const RSkeleton(height: 120);
    if (_error != null) return ProErrorState(message: _error!, onRetry: _load);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        RCard(child: Text(_profile.toString(), style: const TextStyle(fontSize: RTokens.textSm))),
        const SizedBox(height: RTokens.spacingX3),
        Wrap(
          spacing: RTokens.spacingX2,
          children: [
            TextButton(onPressed: () => context.go('/profile/listing-card'), child: const Text('Listing Card')),
            TextButton(onPressed: () => context.go('/pro/profile/packages'), child: const Text('Packages')),
            TextButton(onPressed: () => context.go('/pro/profile/portfolio'), child: const Text('Portfolio')),
          ],
        ),
      ],
    );
  }
}
