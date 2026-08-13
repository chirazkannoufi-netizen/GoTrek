import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models/user_account.dart';
import '../../state/auth_controller.dart';
import 'auth_gate.dart';
import 'widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.returnOnSuccess = false});

  /// Set when opened by [AuthGate]: on success the whole auth flow closes and
  /// hands control back to the action the user was trying to take, instead of
  /// resetting them to the home screen.

  final bool returnOnSuccess;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserAccount?> auth = ref.watch(authControllerProvider);
    final bool isBusy = auth.isLoading;

    ref.listen<AsyncValue<UserAccount?>>(authControllerProvider, (
      AsyncValue<UserAccount?>? previous,
      AsyncValue<UserAccount?> next,
    ) {
      if (next.hasError) {
        showMessage(context, next.error.toString());
      } else if (next.value != null) {
        if (widget.returnOnSuccess) {
          AuthGate.finish(context);
        } else {
          AppRoutes.goHome(context);
        }
      }
    });

    return AuthScaffold(
      isLogin: true,
      returnOnSuccess: widget.returnOnSuccess,
      title: 'Welcome back',
      subtitle: 'Sign in to pick up where you left off.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
              validator: Validators.email,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              validator: Validators.loginPassword,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showNotConnected(context, 'Password reset'),
                child: const Text('Forgot password?'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: isBusy ? null : _submit,
              child:
                  isBusy
                      ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
