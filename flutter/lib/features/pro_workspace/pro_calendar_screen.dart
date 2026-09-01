import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'widgets.dart';

class ProCalendarScreen extends ConsumerStatefulWidget {
  const ProCalendarScreen({super.key});

  @override
  ConsumerState<ProCalendarScreen> createState() => _ProCalendarScreenState();
}

class _ProCalendarScreenState extends ConsumerState<ProCalendarScreen> {
  final _rules = TextEditingController(text: '{}');
  final _exceptions = TextEditingController(text: '{}');
  final _policy = TextEditingController(text: '{}');
  final _date = TextEditingController();

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _slots;

  Future<void> _saveRules() async {
    await ref.read(proApiProvider).putAvailabilityRules((jsonDecode(_rules.text) as Map).cast<String, dynamic>());
  }

  Future<void> _saveExceptions() async {
    await ref.read(proApiProvider).putSchedulingExceptions((jsonDecode(_exceptions.text) as Map).cast<String, dynamic>());
  }

  Future<void> _savePolicy() async {
    await ref.read(proApiProvider).putSchedulingPolicy((jsonDecode(_policy.text) as Map).cast<String, dynamic>());
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
      _slots = null;
    });
    final result = await ref.read(proApiProvider).getCandidateSlots(_date.text.trim().isEmpty ? {} : {'date': _date.text.trim()});
    if (!mounted) return;
    if (!result.ok) {
      setState(() {
        _loading = false;
        _error = result.error?.message ?? 'Failed to load slots';
      });
      return;
    }
    setState(() {
      _loading = false;
      _slots = result.data;
    });
  }

  @override
  void dispose() {
    _rules.dispose();
    _exceptions.dispose();
    _policy.dispose();
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Calendar', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Availability Rules', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _rules, maxLines: 5, hintText: '{}'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Save rules', variant: RButtonVariant.secondary, onPressed: _saveRules),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Exceptions', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _exceptions, maxLines: 4, hintText: '{}'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Save exceptions', variant: RButtonVariant.secondary, onPressed: _saveExceptions),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _policy, maxLines: 4, hintText: '{}'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Save policy', variant: RButtonVariant.secondary, onPressed: _savePolicy),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Candidate Slots', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _date, hintText: 'YYYY-MM-DD'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: _loading ? 'Loading...' : 'Load slots', onPressed: _loading ? null : _loadSlots),
                if (_error != null) ...[
                  const SizedBox(height: RTokens.spacingX2),
                  Text(_error!, style: const TextStyle(color: RTokens.statusDanger)),
                ],
                if (_slots != null) ...[
                  const SizedBox(height: RTokens.spacingX2),
                  Text(_slots.toString(), style: const TextStyle(fontSize: RTokens.textSm)),
                ],
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          const ProEmptyState(title: 'Tip', body: 'Use JSON payloads from backend docs for exact schedule shapes.'),
        ],
      ),
    );
  }
}
