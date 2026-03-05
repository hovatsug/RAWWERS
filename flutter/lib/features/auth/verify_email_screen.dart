import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RTokens.spacingX4),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: RCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verify Email', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: RTokens.spacingX3),
                    RTextField(controller: _emailController, hintText: 'Email'),
                    const SizedBox(height: RTokens.spacingX2),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Request code',
                        variant: RButtonVariant.secondary,
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).requestVerifyEmail(email: _emailController.text.trim());
                          if (!mounted) return;
                          setState(() => _status = 'Verification code requested.');
                        },
                      ),
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _codeController, hintText: 'Verification code'),
                    const SizedBox(height: RTokens.spacingX2),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Confirm verification',
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).confirmVerifyEmail(code: _codeController.text.trim());
                          if (!mounted) return;
                          setState(() => _status = 'Email verified.');
                        },
                      ),
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: RTokens.spacingX2),
                      Text(_status!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
