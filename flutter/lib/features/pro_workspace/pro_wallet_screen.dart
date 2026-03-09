import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import '../../design/widgets/r_text_field.dart';
import 'widgets.dart';

class ProWalletScreen extends ConsumerStatefulWidget {
  const ProWalletScreen({super.key});

  @override
  ConsumerState<ProWalletScreen> createState() => _ProWalletScreenState();
}

class _ProWalletScreenState extends ConsumerState<ProWalletScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _balance = {};
  Map<String, dynamic> _account = {};

  final _accountPayload = TextEditingController(text: '{}');
  final _requestPayload = TextEditingController(text: '{"amount":0}');

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
    final balance = await api.getEarningsBalance();
    final account = await api.getPayoutAccount();

    if (!mounted) return;

    if (!balance.ok || !account.ok) {
      setState(() {
        _loading = false;
        _error = balance.error?.message ?? account.error?.message ?? 'Could not load wallet';
      });
      return;
    }

    setState(() {
      _loading = false;
      _balance = balance.data ?? {};
      _account = account.data ?? {};
    });
  }

  Future<void> _saveAccount() async {
    await ref.read(proApiProvider).putPayoutAccount((jsonDecode(_accountPayload.text) as Map).cast<String, dynamic>());
    _load();
  }

  Future<void> _requestPayout() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RTokens.spacingX4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Confirm payout request', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: RTokens.spacingX2),
              const Text('This action impacts money movement.'),
              const SizedBox(height: RTokens.spacingX3),
              RButton(label: 'Confirm', onPressed: () => Navigator.of(context).pop(true)),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;

    await ref.read(proApiProvider).requestPayout((jsonDecode(_requestPayload.text) as Map).cast<String, dynamic>());
    await ref.read(proApiProvider).track('pro_payout_requested', {'source': 'flutter'});
    _load();
  }

  @override
  void dispose() {
    _accountPayload.dispose();
    _requestPayload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Column(children: [RSkeleton(height: 96), SizedBox(height: RTokens.spacingX3), RSkeleton(height: 96)]);
    }
    if (_error != null) return ProErrorState(message: _error!, onRetry: _load);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wallet', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Available balance', style: TextStyle(color: RTokens.neutralMuted)),
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
                const Text('Payout account', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                Text(_account.toString(), style: const TextStyle(fontSize: RTokens.textSm, color: RTokens.neutralMuted)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _accountPayload, maxLines: 4, hintText: '{}'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Save account', variant: RButtonVariant.secondary, onPressed: _saveAccount),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Request payout', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _requestPayload, hintText: '{"amount":0}'),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Request payout', onPressed: _requestPayout),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
