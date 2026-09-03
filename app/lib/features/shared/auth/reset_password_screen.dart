import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/password_reset_confirm_request.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/tokens.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({required this.loginPath, super.key});

  final String loginPath;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _code.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _code.text.trim();
    final newPassword = _newPassword.text;
    if (code.isEmpty) {
      setState(() => _error = 'Enter the code we sent you.');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    final client = ref.read(authClientProvider);
    final result = await apiCall(
      () => client.passwordResetConfirmV1AuthPasswordResetConfirmPost(
        requestBody: PasswordResetConfirmRequest(code: code, newPassword: newPassword),
      ),
    );

    if (!mounted) return;
    switch (result) {
      case Ok():
        context.go(widget.loginPath);
      case Err(:final failure):
        setState(() {
          _error = switch (failure) {
            Validation() || BusinessError() => 'That code is invalid or has expired.',
            _ => 'Something went wrong. Please try again.',
          };
          _submitting = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter reset code')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RInput(label: 'Code', controller: _code),
              const SizedBox(height: RSpace.s12),
              RInput(label: 'New password', controller: _newPassword, obscureText: true),
              if (_error != null) ...[
                const SizedBox(height: RSpace.s12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: RSpace.s24),
              RButton(label: 'Reset password', onPressed: _submitting ? null : _submit, loading: _submitting),
            ],
          ),
        ),
      ),
    );
  }
}
