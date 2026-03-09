import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'widgets.dart';

class ProPackagesScreen extends ConsumerStatefulWidget {
  const ProPackagesScreen({super.key});

  @override
  ConsumerState<ProPackagesScreen> createState() => _ProPackagesScreenState();
}

class _ProPackagesScreenState extends ConsumerState<ProPackagesScreen> {
  final _payload = TextEditingController(text: '{"title":"","price_per_photo":0,"min_photo_qty":0}');
  final _updatePayload = TextEditingController(text: '{}');
  final _packageId = TextEditingController();

  String? _error;
  String? _result;

  Future<void> _create() async {
    final res = await ref.read(proApiProvider).createPackage((jsonDecode(_payload.text) as Map).cast<String, dynamic>());
    if (!mounted) return;
    setState(() {
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
      _result = res.ok ? res.data.toString() : null;
    });
  }

  Future<void> _update() async {
    final id = _packageId.text.trim();
    if (id.isEmpty) return;
    final res = await ref.read(proApiProvider).updatePackage(id, (jsonDecode(_updatePayload.text) as Map).cast<String, dynamic>());
    if (!mounted) return;
    setState(() {
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
      _result = res.ok ? res.data.toString() : null;
    });
  }

  Future<void> _disable() async {
    final id = _packageId.text.trim();
    if (id.isEmpty) return;
    final res = await ref.read(proApiProvider).disablePackage(id);
    if (!mounted) return;
    setState(() {
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
      _result = res.ok ? res.data.toString() : null;
    });
  }

  @override
  void dispose() {
    _payload.dispose();
    _updatePayload.dispose();
    _packageId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Packages', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
          const SizedBox(height: RTokens.spacingX3),
          const ProEmptyState(title: 'From price rule', body: 'From price = pricePerPhoto * minPhotoQty (derived, not typed manually).'),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create package'),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _payload, maxLines: 5),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Create', onPressed: _create),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Update / Disable package'),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _packageId, hintText: 'package id'),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _updatePayload, maxLines: 4),
                const SizedBox(height: RTokens.spacingX2),
                Row(
                  children: [
                    Expanded(child: RButton(label: 'Update', variant: RButtonVariant.secondary, onPressed: _update)),
                    const SizedBox(width: RTokens.spacingX2),
                    Expanded(child: RButton(label: 'Disable', variant: RButtonVariant.ghost, onPressed: _disable)),
                  ],
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: RTokens.spacingX2),
            Text(_error!, style: const TextStyle(color: RTokens.statusDanger)),
          ],
          if (_result != null) ...[
            const SizedBox(height: RTokens.spacingX2),
            Text(_result!, style: const TextStyle(fontSize: RTokens.textSm)),
          ],
        ],
      ),
    );
  }
}
