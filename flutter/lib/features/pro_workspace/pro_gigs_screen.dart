import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'widgets.dart';

class ProGigsScreen extends ConsumerStatefulWidget {
  const ProGigsScreen({super.key});

  @override
  ConsumerState<ProGigsScreen> createState() => _ProGigsScreenState();
}

class _ProGigsScreenState extends ConsumerState<ProGigsScreen> {
  final _gigId = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _gig;

  Future<void> _openGig() async {
    final id = _gigId.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _gig = null;
    });

    final result = await ref.read(proApiProvider).getGig(id);
    if (!mounted) return;

    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Could not open gig';
      });
      return;
    }

    setState(() {
      _loading = false;
      _gig = result.data;
    });
  }

  @override
  void dispose() {
    _gigId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gigs', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
        const SizedBox(height: RTokens.spacingX3),
        const ProEmptyState(title: 'No list endpoint', body: 'Open gigs by id or from leads/thread metadata.'),
        const SizedBox(height: RTokens.spacingX3),
        RCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RTextField(controller: _gigId, hintText: 'Paste gig id'),
              const SizedBox(height: RTokens.spacingX3),
              RButton(label: _loading ? 'Loading...' : 'Open gig', onPressed: _loading ? null : _openGig),
              if (_error != null) ...[
                const SizedBox(height: RTokens.spacingX2),
                Text(_error!, style: const TextStyle(color: RTokens.statusDanger)),
              ],
              if (_gig != null) ...[
                const SizedBox(height: RTokens.spacingX3),
                Text(_gig.toString(), style: const TextStyle(fontSize: RTokens.textSm)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
