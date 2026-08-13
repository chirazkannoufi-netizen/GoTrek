import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/feedback.dart';
import '../../../data/seed/seed_catalog.dart';
import '../login_screen.dart';
import '../sign_up_screen.dart';

/// Shared chrome for the login and sign-up screens: brand header, the
/// Log in / Sign up switch, the form, and the footer.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.isLogin,
    required this.title,
    required this.subtitle,
    required this.form,
    this.returnOnSuccess = false,
  });

  final bool isLogin;

  /// True when this screen was opened by [AuthGate]; the Log in / Sign up
  /// switch then pushes rather than replaces, so the gate's own route stays
  /// on the stack for AuthGate.finish to unwind to.
  final bool returnOnSuccess;
  final String title;
  final String subtitle;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.xxl,
                AppSpacing.huge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      SeedCatalog.logoImage,
                      height: 64,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? _) =>
                              Text(
                                'GoTrek',
                                style: theme.textTheme.headlineSmall,
                              ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  _AuthSwitch(
                    isLogin: isLogin,
                    returnOnSuccess: returnOnSuccess,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  form,
                  const SizedBox(height: AppSpacing.xxxl),
                  const _SocialRow(),
                  const SizedBox(height: AppSpacing.xxxl),
                  const _FooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch({required this.isLogin, required this.returnOnSuccess});

  final bool isLogin;
  final bool returnOnSuccess;

  void _go(BuildContext context, Widget screen, String namedRoute) {
    if (returnOnSuccess) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<bool>(builder: (_) => screen));
    } else {
      Navigator.of(context).pushReplacementNamed(namedRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: <Widget>[
          _SwitchTab(
            label: 'Log in',
            selected: isLogin,
            onTap:
                isLogin
                    ? null
                    : () => _go(
                      context,
                      const LoginScreen(returnOnSuccess: true),
                      AppRoutes.login,
                    ),
          ),
          _SwitchTab(
            label: 'Sign up',
            selected: !isLogin,
            onTap:
                isLogin
                    ? () => _go(
                      context,
                      const SignUpScreen(returnOnSuccess: true),
                      AppRoutes.signUp,
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}

class _SwitchTab extends StatelessWidget {
  const _SwitchTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color:
                  selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                'or continue with',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              label: 'Google sign-in',
            ),
            SizedBox(width: AppSpacing.lg),
            _SocialButton(icon: Icons.facebook, label: 'Facebook sign-in'),
            SizedBox(width: AppSpacing.lg),
            _SocialButton(icon: Icons.apple, label: 'Apple sign-in'),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Tooltip(
      message: label,
      child: OutlinedButton(
        onPressed: () => showNotConnected(context, label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          fixedSize: const Size(64, 52),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 26, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const List<String> labels = <String>[
      'Privacy policy',
      'Terms',
      'Help centre',
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      children: <Widget>[
        for (final String label in labels)
          TextButton(
            onPressed: () => showNotConnected(context, label),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              textStyle: theme.textTheme.bodySmall,
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            child: Text(label),
          ),
      ],
    );
  }
}
