import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/cards/hotel_card.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/hotel.dart';
import '../../data/models/place_category.dart';
import '../../state/catalog_providers.dart';

/// The stays list. Search and sort are wired to the filter provider — the
/// original screen rendered a static "Sort By: Price (Low to High)" label and
/// a search box that was not connected to anything.
class StaysScreen extends ConsumerWidget {
  const StaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final StaysFilter filter = ref.watch(staysFilterProvider);
    final StaysFilterNotifier controller = ref.read(
      staysFilterProvider.notifier,
    );
    final AsyncValue<List<Hotel>> hotels = ref.watch(filteredHotelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stays')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: AppSearchField(
              hintText: 'Search hotels',
              initialValue: filter.query,
              onChanged: controller.setQuery,
            ),
          ),
          Padding(
            padding: AppSpacing.pageHorizontal,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.sort,
                  size: AppTheme.iconInline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Sort by', style: theme.textTheme.bodyMedium),
                const Spacer(),
                DropdownButtonHideUnderline(
                  child: DropdownButton<HotelSort>(
                    value: filter.sort,
                    borderRadius: AppRadius.allMd,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    onChanged: (HotelSort? value) {
                      if (value != null) controller.setSort(value);
                    },
                    items: <DropdownMenuItem<HotelSort>>[
                      for (final HotelSort sort in HotelSort.values)
                        DropdownMenuItem<HotelSort>(
                          value: sort,
                          child: Text(sort.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: hotels.when(
              loading: () => const LoadingView(),
              error:
                  (Object error, StackTrace _) => ErrorView(
                    message: describeCatalogError(error),
                    onRetry: () => ref.invalidate(hotelsProvider),
                  ),
              data: (List<Hotel> results) {
                if (results.isEmpty) {
                  return EmptyView(
                    title: 'No stays match "${filter.query}"',
                    message: 'Try a different hotel or area name.',
                    icon: Icons.hotel_outlined,
                    action: FilledButton.tonal(
                      onPressed: () => controller.setQuery(''),
                      child: const Text('Clear search'),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => refreshCatalog(ref),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.huge,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 560,
                          mainAxisExtent: HotelCard.height,
                          crossAxisSpacing: AppSpacing.lg,
                          mainAxisSpacing: AppSpacing.lg,
                        ),
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Hotel hotel = results[index];
                      return HotelCard(
                        hotel: hotel,
                        onTap: () => AppRoutes.openHotel(context, hotel),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
