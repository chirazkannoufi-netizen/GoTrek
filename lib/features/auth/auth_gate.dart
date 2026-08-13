import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../state/auth_controller.dart';
import 'login_screen.dart';

/// Sign-in gate for account-specific actions.
///
/// Browsing is open to everyone; only actions that belong to an account —
/// booking, checkout, saving a place — go through here. If the user is
/// already signed in this is a no-op, so callers can simply `await` it.
abstract final class AuthGate {
  /// Marks the route the gate pushed, so [finish] can unwind however many
  /// steps the user took (log in, or sign up and confirm a code) in one go.
  static const String routeName = 'auth-gate';

  /// Closes the whole auth flow and reports success to whoever opened it.
  static void finish(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.popUntil(
      (Route<dynamic> route) =>
          route.settings.name == routeName || route.isFirst,
    );
    if (navigator.canPop()) navigator.pop(true);
  }
}

/// Returns `true` once there is a signed-in user, `false` if the user backed
/// out. Shows an explanation first so the prompt never appears unexplained.
Future<bool> ensureSignedIn(
  BuildContext context,
  WidgetRef ref, {
  required String action,
}) async {
  // Await the session rather than reading it: on a cold start the controller
  // may still be restoring from disk, and a signed-in user must not be shown
  // a sign-in prompt because the read landed a frame too early.
  if (await ref.read(authControllerProvider.future) != null) return true;
  if (!context.mounted) return false;

  final bool? wantsToSignIn = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext context) => _SignInPromptSheet(action: action),
  );
  if (wantsToSignIn != true || !context.mounted) return false;

  final bool? signedIn = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      settings: const RouteSettings(name: AuthGate.routeName),
      builder: (_) => const LoginScreen(returnOnSuccess: true),
    ),
  );
  return signedIn ?? false;
}

class _SignInPromptSheet extends StatelessWidget {
  const _SignInPromptSheet({required this.action});

  /// Phrased to complete "Sign in to …", e.g. "save this place".
  final String action;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sign in to $action',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can keep browsing without an account — this bit just needs '
              'one so it stays with you.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log in or sign up'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
