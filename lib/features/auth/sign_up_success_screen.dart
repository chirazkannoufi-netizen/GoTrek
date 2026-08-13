import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../state/auth_controller.dart';
import 'auth_gate.dart';

/// Confirmation shown once an account has been created.
class SignUpSuccessScreen extends ConsumerWidget {
  const SignUpSuccessScreen({super.key, this.returnOnSuccess = false});

  /// See [LoginScreen.returnOnSuccess].
  final bool returnOnSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String? firstName =
        ref.watch(currentUserProvider)?.fullName.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.celebration_outlined,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    firstName == null
                        ? 'You are all set'
                        : 'You are all set, $firstName',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Your account is ready. Start with the places travellers '
                    'book most, or search for somewhere specific.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.huge),
                  FilledButton(
                    onPressed:
                        () =>
                            returnOnSuccess
                                ? AuthGate.finish(context)
                                : AppRoutes.goHome(context),
                    child: Text(
                      returnOnSuccess ? 'Continue' : 'Start exploring',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
