import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_text_field.dart';
import 'providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
                    Text('Login', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: RTokens.spacingX3),
                    RTextField(controller: _emailController, hintText: 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: RTokens.spacingX2),
                    RTextField(controller: _passwordController, hintText: 'Password', obscureText: true),
                    const SizedBox(height: RTokens.spacingX3),
                    SizedBox(
                      width: double.infinity,
                      child: RButton(
                        label: 'Login',
                        isLoading: state.loading,
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).login(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                        },
                      ),
                    ),
                    const SizedBox(height: RTokens.spacingX2),
                    Row(
                      children: [
                        RButton(
                          label: 'Register',
                          variant: RButtonVariant.ghost,
                          onPressed: () => context.push('/register'),
                        ),
                        RButton(
                          label: 'Pro login',
                          variant: RButtonVariant.ghost,
                          onPressed: () => context.push('/pro/login'),
                        ),
                        RButton(
                          label: 'Reset password',
                          variant: RButtonVariant.ghost,
                          onPressed: () => context.push('/reset-password'),
                        ),
                      ],
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
