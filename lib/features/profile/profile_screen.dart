import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models/user_account.dart';
import '../../state/auth_controller.dart';
import '../../state/bookings_controller.dart';
import '../../state/favorites_controller.dart';
import '../auth/auth_gate.dart';

/// Profile tab.
///
/// Reachable without an account: guests get a sign-in card here rather than
/// being blocked out of the rest of the app.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserAccount? user = ref.watch(currentUserProvider);
    final bool signedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        children: <Widget>[
          const SizedBox(height: AppSpacing.sm),
          if (signedIn) ...<Widget>[
            _SignedInHeader(user: user),
            const SizedBox(height: AppSpacing.xl),
            const _Stats(),
          ] else
            const _GuestCard(),
          const SizedBox(height: AppSpacing.xl),
          _MenuTile(
            icon: Icons.confirmation_number_outlined,
            title: 'My bookings',
            onTap: () async {
              if (!await ensureSignedIn(
                context,
                ref,
                action: 'see your bookings',
              )) {
                return;
              }
              if (context.mounted) await AppRoutes.openBookings(context);
            },
          ),
          _MenuTile(
            icon: Icons.person_outline,
            title: 'Personal information',
            onTap: () async {
              if (!await ensureSignedIn(
                context,
                ref,
                action: 'see your details',
              )) {
                return;
              }
              if (context.mounted) {
                _showPersonalInfo(context, ref.read(currentUserProvider));
              }
            },
          ),
          _MenuTile(
            icon: Icons.payment_outlined,
            title: 'Payment methods',
            onTap: () => showNotConnected(context, 'Payment methods'),
          ),
          _MenuTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            onTap: () => showNotConnected(context, 'Notifications'),
          ),
          _MenuTile(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            onTap: () => showNotConnected(context, 'Support'),
          ),
          if (signedIn) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: AppSpacing.pageHorizontal,
              child: _LogOutButton(onConfirmed: () => _signOut(context, ref)),
            ),
          ],
        ],
      ),
    );
  }

  void _showPersonalInfo(BuildContext context, UserAccount? user) {
    if (user == null) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Personal information', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(label: 'Name', value: user.fullName),
                _InfoRow(label: 'Email', value: user.email),
                _InfoRow(label: 'Phone', value: user.phone ?? 'Not provided'),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Signing out returns to the home tab, not the login screen — the app
  /// stays usable as a guest.
  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) showMessage(context, 'You are signed out.');
  }
}

class _SignedInHeader extends StatelessWidget {
  const _SignedInHeader({required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user.initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(user.fullName, style: theme.textTheme.titleLarge),
          Text(
            user.email,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The signed-out state of the Profile tab.
class _GuestCard extends ConsumerWidget {
  const _GuestCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_outline,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'You are browsing as a guest',
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sign in to save places and keep your bookings.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed:
                    () => ensureSignedIn(
                      context,
                      ref,
                      action: 'use your account',
                    ),
                child: const Text('Log in or sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stats extends ConsumerWidget {
  const _Stats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int savedCount = ref.watch(favoritesCountProvider);
    final int upcoming = ref.watch(upcomingBookingsCountProvider);

    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatCard(
              label: 'Saved places',
              value: '$savedCount',
              icon: Icons.favorite_border,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _StatCard(
              label: 'Upcoming trips',
              value: '$upcoming',
              icon: Icons.luggage_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onConfirmed});

  final Future<void> Function() onConfirmed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: () async {
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text(
                  'Your saved places and bookings stay on this device.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Log out'),
                  ),
                ],
              ),
        );
        if (confirmed ?? false) await onConfirmed();
      },
      icon: Icon(Icons.logout, color: theme.colorScheme.error),
      label: Text('Log out', style: TextStyle(color: theme.colorScheme.error)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: theme.textTheme.headlineSmall),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
