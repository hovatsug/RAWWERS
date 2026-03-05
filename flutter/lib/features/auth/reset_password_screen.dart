import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _status;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
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
                    Text('Reset Password', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: RTokens.spacingX3),
                    RTextField(controller: _emailController, hintText: 'Email'),
                    const SizedBox(height: RTokens.spacingX2),
                    RButton(
                      label: 'Request reset code',
                      variant: RButtonVariant.secondary,
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).requestPasswordReset(email: _emailController.text.trim());
                        if (!mounted) return;
                        setState(() => _status = 'Reset code requested.');
                      },
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _codeController, hintText: 'Reset code'),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _passwordController, hintText: 'New password', obscureText: true),
                    const SizedBox(height: RTokens.spacingX2),
                    RButton(
                      label: 'Confirm reset',
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).confirmPasswordReset(
                              code: _codeController.text.trim(),
                              newPassword: _passwordController.text,
                            );
                        if (!mounted) return;
                        setState(() => _status = 'Password updated.');
                      },
                    ),
                    if (_status != null) ...[
                      const SizedBox(height: RTokens.spacingX2),
                      Text(_status!),
                    ]
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
