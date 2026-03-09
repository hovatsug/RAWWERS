import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'providers.dart';

class ProLoginScreen extends ConsumerStatefulWidget {
  const ProLoginScreen({super.key});

  @override
  ConsumerState<ProLoginScreen> createState() => _ProLoginScreenState();
}

class _ProLoginScreenState extends ConsumerState<ProLoginScreen> {
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
                    Text('Pro Login', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: RTokens.spacingX3),
                    RTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _passwordController, hintText: 'Password', obscureText: true),
                    const SizedBox(height: RTokens.spacingX3),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Login as Pro',
                        isLoading: state.loading,
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).loginAsPro(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                          final next = ref.read(authControllerProvider);
                          if (next.me?.roles.contains('pro') == true && context.mounted) {
                            context.go('/pro/dashboard');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    RButton(
                      label: 'Register as Pro',
                      variant: RButtonVariant.ghost,
                      onPressed: () => context.push('/pro/register'),
                    ),
                    if (state.error != null) ...[
                      const SizedBox(height: RTokens.spacingX2),
                      Text(state.error!, style: const TextStyle(color: RTokens.statusDanger)),
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
