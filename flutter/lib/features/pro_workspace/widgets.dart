import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_card.dart';

class ProEmptyState extends StatelessWidget {
  const ProEmptyState({super.key, required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: RTokens.textLg, fontWeight: FontWeight.w600)),
          if (body != null) ...[
            const SizedBox(height: RTokens.spacingX2),
            Text(body!, style: const TextStyle(fontSize: RTokens.textSm, color: RTokens.neutralMuted)),
          ],
        ],
      ),
    );
  }
}

class ProErrorState extends StatelessWidget {
  const ProErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: RTokens.statusDanger)),
          const SizedBox(height: RTokens.spacingX2),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
