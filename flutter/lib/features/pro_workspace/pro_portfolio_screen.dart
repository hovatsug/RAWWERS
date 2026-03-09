import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/pro_api_provider.dart';
import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'widgets.dart';

class ProPortfolioScreen extends ConsumerStatefulWidget {
  const ProPortfolioScreen({super.key});

  @override
  ConsumerState<ProPortfolioScreen> createState() => _ProPortfolioScreenState();
}

class _ProPortfolioScreenState extends ConsumerState<ProPortfolioScreen> {
  final _createPayload = TextEditingController(text: '{"filename":"image.jpg","content_type":"image/jpeg"}');
  final _mediaId = TextEditingController();
  final _completePayload = TextEditingController(text: '{}');
  final _tagPayload = TextEditingController(text: '{"niche_slugs":[]}');

  String? _result;
  String? _error;

  Future<void> _createUpload() async {
    final res = await ref.read(proApiProvider).createPhotoUpload((jsonDecode(_createPayload.text) as Map).cast<String, dynamic>());
    if (!mounted) return;
    setState(() {
      _result = res.ok ? res.data.toString() : null;
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
    });
  }

  Future<void> _completeUpload() async {
    final id = _mediaId.text.trim();
    if (id.isEmpty) return;
    final res = await ref.read(proApiProvider).completePhotoUpload(id, (jsonDecode(_completePayload.text) as Map).cast<String, dynamic>());
    if (!mounted) return;
    setState(() {
      _result = res.ok ? res.data.toString() : null;
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
    });
  }

  Future<void> _tagMedia() async {
    final id = _mediaId.text.trim();
    if (id.isEmpty) return;
    final res = await ref.read(proApiProvider).tagPortfolioMediaNiches(id, (jsonDecode(_tagPayload.text) as Map).cast<String, dynamic>());
    if (!mounted) return;
    setState(() {
      _result = res.ok ? res.data.toString() : null;
      _error = res.ok ? null : (res.error?.message ?? 'Failed');
    });
  }

  @override
  void dispose() {
    _createPayload.dispose();
    _mediaId.dispose();
    _completePayload.dispose();
    _tagPayload.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfolio', style: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w700)),
          const SizedBox(height: RTokens.spacingX3),
          const ProEmptyState(title: 'Upload flow', body: 'Create upload target -> upload binary -> complete -> tag niches.'),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create upload target'),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _createPayload, maxLines: 4),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Create upload', onPressed: _createUpload),
              ],
            ),
          ),
          const SizedBox(height: RTokens.spacingX3),
          RCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RTextField(controller: _mediaId, hintText: 'media asset id'),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _completePayload, maxLines: 3),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Complete upload', variant: RButtonVariant.secondary, onPressed: _completeUpload),
                const SizedBox(height: RTokens.spacingX2),
                RTextField(controller: _tagPayload, maxLines: 3),
                const SizedBox(height: RTokens.spacingX2),
                RButton(label: 'Tag media niches', variant: RButtonVariant.ghost, onPressed: _tagMedia),
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
