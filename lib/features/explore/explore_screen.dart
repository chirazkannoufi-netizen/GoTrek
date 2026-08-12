import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/cards/destination_card.dart';
import '../../core/widgets/category_chips.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/destination.dart';
import '../../state/catalog_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ExploreFilter filter = ref.watch(exploreFilterProvider);
    final ExploreFilterNotifier controller = ref.read(
      exploreFilterProvider.notifier,
    );
    final AsyncValue<List<Destination>> destinations = ref.watch(
      filteredDestinationsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        automaticallyImplyLeading: false,
      ),
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
              hintText: 'Search destinations',
              initialValue: filter.query,
              onChanged: controller.setQuery,
            ),
          ),
          CategoryChips(
            selected: filter.category,
            onSelected: controller.toggleCategory,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: destinations.when(
              loading: () => const LoadingView(),
              error:
                  (Object error, StackTrace _) => ErrorView(
                    message: describeCatalogError(error),
                    onRetry: () => ref.invalidate(destinationsProvider),
                  ),
              data:
                  (List<Destination> results) => _Results(
                    results: results,
                    filter: filter,
                    onClearFilters: controller.clear,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.results,
    required this.filter,
    required this.onClearFilters,
  });

  final List<Destination> results;
  final ExploreFilter filter;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    if (results.isEmpty) {
      return EmptyView(
        title: 'No destinations match that',
        message:
            filter.category == null
                ? 'Try a different search term.'
                : 'Nothing in ${filter.category!.label} matches "${filter.query}".',
        action: FilledButton.tonal(
          onPressed: onClearFilters,
          child: const Text('Clear filters'),
        ),
      );
    }

    final Destination hero = results.first;
    final List<Destination> rest = results.skip(1).toList();

    return RefreshIndicator(
      onRefresh: () => refreshCatalog(ref),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: AppSpacing.pageHorizontal,
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '${results.length} '
                          '${results.length == 1 ? 'destination' : 'destinations'}'
                          '${filter.category == null ? '' : ' in ${filter.category!.label}'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (filter.isActive)
                        TextButton(
                          onPressed: onClearFilters,
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DestinationHeroCard(
                    destination: hero,
                    onTap: () => AppRoutes.openDestination(context, hero),
                  ),
                ],
              ),
            ),
          ),
          if (rest.isNotEmpty) ...<Widget>[
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            SliverPadding(
              padding: AppSpacing.pageHorizontal,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'More destinations',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverPadding(
              padding: AppSpacing.pageHorizontal,
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 560,
                  mainAxisExtent: 116,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                itemCount: rest.length,
                itemBuilder: (BuildContext context, int index) {
                  final Destination destination = rest[index];
                  return DestinationListCard(
                    destination: destination,
                    onTap:
                        () => AppRoutes.openDestination(context, destination),
                  );
                },
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.huge)),
        ],
      ),
    );
  }
}
