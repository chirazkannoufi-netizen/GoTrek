import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/city_cover.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/booking.dart';
import '../../data/models/booking_draft.dart';
import '../../data/models/payment_card.dart';
import '../../state/bookings_controller.dart';
import '../../state/catalog_providers.dart';
import 'booking_confirmed_screen.dart';

/// Checkout for a [BookingDraft].
///
/// The draft carries the real total through from whichever detail screen
/// started it — the original passed `totalPrice: ''` from the flight screen,
/// so the payment page showed a bare dollar sign.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedCardId;
  bool _isPaying = false;

  BookingDraft get _draft => widget.draft;

  Future<void> _pay(List<PaymentCard> cards) async {
    final PaymentCard card = cards.firstWhere(
      (PaymentCard c) => c.id == _selectedCardId,
    );

    setState(() => _isPaying = true);
    final Booking booking = await ref
        .read(bookingsControllerProvider.notifier)
        .confirm(draft: _draft, paymentLabel: card.label);

    if (!mounted) return;
    setState(() => _isPaying = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => BookingConfirmedScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<PaymentCard>> cards = ref.watch(paymentCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cards.when(
        loading: () => const LoadingView(),
        error:
            (Object error, StackTrace _) =>
                ErrorView(message: describeCatalogError(error)),
        data:
            (List<PaymentCard> available) => ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.huge,
              ),
              children: <Widget>[
                _SummaryCard(draft: _draft),
                const SizedBox(height: AppSpacing.xxl),
                Text('Price details', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _PriceBreakdown(draft: _draft),
                const SizedBox(height: AppSpacing.xxl),
                Text('Pay with', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                for (final PaymentCard card in available)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CardOption(
                      card: card,
                      selected: card.id == _selectedCardId,
                      onSelected:
                          () => setState(() => _selectedCardId = card.id),
                    ),
                  ),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      'Add a new card',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showNotConnected(context, 'Adding a card'),
                  ),
                ),
              ],
            ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Total', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    Formatters.moneyPrecise(_draft.total),
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed:
                    _selectedCardId == null || _isPaying
                        ? null
                        : () => _pay(cards.value ?? const <PaymentCard>[]),
                child:
                    _isPaying
                        ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          _selectedCardId == null
                              ? 'Select a payment method'
                              : 'Confirm and pay',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String dates =
        draft.kind == BookingKind.experience
            ? '${Formatters.dayMonth(draft.startDate)} · '
                '${Formatters.time(draft.startDate)}'
            : '${Formatters.shortDate(draft.startDate)} → '
                '${Formatters.shortDate(draft.endDate)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: <Widget>[
            CityCover(
              imageAsset: draft.imageAsset,
              title: draft.title,
              width: 88,
              height: 88,
              borderRadius: AppRadius.allMd,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        draft.kind.icon,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        draft.kind.label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    draft.title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    draft.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(dates, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.draft});

  final BookingDraft draft;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: <Widget>[
            for (final BookingLineItem item in draft.lineItems)
              _Line(label: item.label, amount: item.amount),
            _Line(label: 'Service fee', amount: draft.serviceFee),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            Row(
              children: <Widget>[
                Text('Total', style: theme.textTheme.titleMedium),
                const Spacer(),
                Text(
                  Formatters.moneyPrecise(draft.total),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            Formatters.moneyPrecise(amount),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CardOption extends StatelessWidget {
  const _CardOption({
    required this.card,
    required this.selected,
    required this.onSelected,
  });

  final PaymentCard card;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.allLg,
        side: BorderSide(
          color:
              selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelected,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(card.brand.icon, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(card.label, style: theme.textTheme.titleSmall),
                    Text(
                      'Expires ${card.expiryLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
