import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import 'widgets.dart';

class ProLeadsScreen extends ConsumerStatefulWidget {
  const ProLeadsScreen({super.key});

  @override
  ConsumerState<ProLeadsScreen> createState() => _ProLeadsScreenState();
}

class _ProLeadsScreenState extends ConsumerState<ProLeadsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _items = const [];

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
    final result = await ref.read(proApiProvider).listProThreads({'limit': 50});
    if (!mounted) return;

    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Could not load leads';
      });
      return;
    }

    setState(() {
      _items = (result.data?['items'] as List<dynamic>?) ?? const [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(
        children: [RSkeleton(height: 72), SizedBox(height: RTokens.spacingX3), RSkeleton(height: 72)],
      );
    }
    if (_error != null) return ProErrorState(message: _error!, onRetry: _load);
    if (_items.isEmpty) return const ProEmptyState(title: 'No leads yet', body: 'Leads are derived from thread contexts.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leads', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        ..._items.map((item) {
          final map = (item as Map).cast<String, dynamic>();
          final gigId = map['gig_id']?.toString();
          final requestId = map['booking_request_id']?.toString() ?? map['request_id']?.toString();
          return Padding(
            padding: const EdgeInsets.only(bottom: RTokens.spacingX3),
            child: RCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(map['title']?.toString() ?? map['subject']?.toString() ?? 'Thread', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: RTokens.spacingX1),
                        Text('request: ${requestId ?? '-'}', style: const TextStyle(color: RTokens.neutralMuted, fontSize: RTokens.textSm)),
                      ],
                    ),
                  ),
                  if (gigId != null)
                    TextButton(
                      onPressed: () => context.go('/pro/gigs/$gigId'),
                      child: const Text('Open gig'),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
