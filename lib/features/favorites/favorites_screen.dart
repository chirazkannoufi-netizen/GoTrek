import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/cards/catalog_item_card.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/catalog_item.dart';
import '../../data/seed/seed_catalog.dart';
import '../../state/favorites_controller.dart';
import '../../state/navigation_controller.dart';

/// Everything the user has saved.
///
/// The original screen was hard-coded to the empty illustration and could
/// never show anything, because there was nothing storing favourites.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CatalogItem>> saved = ref.watch(savedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          if ((saved.value ?? const <CatalogItem>[]).isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('Clear all'),
            ),
        ],
      ),
      body: saved.when(
        loading: () => const LoadingView(),
        error:
            (Object error, StackTrace _) => ErrorView(
              message: 'Could not load your saved places.',
              onRetry: () => ref.invalidate(savedItemsProvider),
            ),
        data: (List<CatalogItem> items) {
          if (items.isEmpty) {
            return EmptyView(
              title: 'Nothing saved yet',
              message:
                  'Tap the heart on a destination, stay or experience to '
                  'keep it here.',
              imageAsset: SeedCatalog.emptyFavouritesImage,
              action: FilledButton(
                onPressed:
                    () => ref
                        .read(navigationProvider.notifier)
                        .select(AppTab.home),
                child: const Text('Start browsing'),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.huge,
            ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 560,
              mainAxisExtent: 132,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final CatalogItem item = items[index];
              return CatalogItemCard(
                item: item,
                onTap: () => AppRoutes.openCatalogItem(context, item),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Clear saved places?'),
            content: const Text(
              'This removes everything from your saved list.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear all'),
              ),
            ],
          ),
    );

    if (confirmed ?? false) {
      await ref.read(favoritesControllerProvider.notifier).clear();
    }
  }
}
