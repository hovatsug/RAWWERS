import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
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
                    Text('Register', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: RTokens.spacingX3),
                    RTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _passwordController, hintText: 'Password', obscureText: true),
                    const SizedBox(height: RTokens.spacingX3),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Create account',
                        isLoading: state.loading,
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ref.read(authControllerProvider.notifier).register(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Registered. Request email verification.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Verify email',
                        variant: RButtonVariant.secondary,
                        onPressed: () => context.push('/verify-email'),
                      ),
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Register as Pro',
                        variant: RButtonVariant.ghost,
                        onPressed: () => context.push('/pro/register'),
                      ),
                    ),
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
