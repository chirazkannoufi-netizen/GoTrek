import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/cards/catalog_item_card.dart';
import '../../core/widgets/cards/hotel_card.dart';
import '../../core/widgets/cards/rail_cards.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/attraction.dart';
import '../../data/models/catalog_item.dart';
import '../../data/models/city_location.dart';
import '../../data/models/experience.dart';
import '../../data/models/hotel.dart';
import '../../data/models/place_category.dart';
import '../../state/auth_controller.dart';
import '../../state/catalog_providers.dart';

/// Home is the screen for **where the user is**: the stays, places and
/// activities in their current city. Trips to other cities live on Explore.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _railHeight = 268;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSearching = ref.watch(homeSearchProvider).trim().isNotEmpty;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => refreshCatalog(ref),
        child: CustomScrollView(
          slivers: <Widget>[
            const _HomeAppBar(),
            if (isSearching)
              const _SearchResults()
            else
              const _CityFeed(railHeight: _railHeight),
          ],
        ),
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget {
  const _HomeAppBar();

  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final CityLocation city = ref.watch(currentCityProvider);
    final String? firstName =
        ref.watch(currentUserProvider)?.fullName.split(' ').first;

    return SliverAppBar(
      floating: true,
      toolbarHeight: 76,
      titleSpacing: AppSpacing.lg,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            firstName == null ? _greeting : '$_greeting, $firstName',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          // Opens the location picker — this used to jump to Explore.
          InkWell(
            borderRadius: AppRadius.allSm,
            onTap: () => AppRoutes.showLocationPicker(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(city.label, style: theme.textTheme.titleSmall),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: AppTheme.iconInline,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => showNotConnected(context, 'Notifications'),
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          // Searches within the current city; it does not redirect anywhere.
          child: AppSearchField(
            hintText: 'Search hotels and places in ${city.city}',
            initialValue: ref.read(homeSearchProvider),
            onChanged: ref.read(homeSearchProvider.notifier).setQuery,
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String query = ref.watch(homeSearchProvider).trim();
    final CityLocation city = ref.watch(currentCityProvider);
    final AsyncValue<List<CatalogItem>> results = ref.watch(
      homeSearchResultsProvider,
    );

    return results.when(
      loading:
          () => const SliverFillRemaining(
            hasScrollBody: false,
            child: LoadingView(),
          ),
      error:
          (Object error, StackTrace _) => SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(message: describeCatalogError(error)),
          ),
      data: (List<CatalogItem> items) {
        if (items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: 'Nothing in ${city.city} matches "$query"',
              message: 'Try a hotel, a landmark or an activity.',
              action: FilledButton.tonal(
                onPressed: ref.read(homeSearchProvider.notifier).clear,
                child: const Text('Clear search'),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.huge,
          ),
          sliver: SliverList.separated(
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    '${items.length} '
                    '${items.length == 1 ? 'result' : 'results'} in '
                    '${city.city}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final CatalogItem item = items[index - 1];
              return CatalogItemCard(
                item: item,
                onTap: () => AppRoutes.openCatalogItem(context, item),
              );
            },
          ),
        );
      },
    );
  }
}

class _CityFeed extends ConsumerWidget {
  const _CityFeed({required this.railHeight});

  final double railHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CityLocation city = ref.watch(currentCityProvider);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: AppSpacing.xs),
          const _ServicesRow(),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Most visited',
            subtitle: 'Landmarks around ${city.city}',
          ),
          const SizedBox(height: AppSpacing.md),
          _AttractionsRail(height: railHeight),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Places to stay',
            subtitle: 'Hotels in ${city.city}',
            actionLabel: 'See all',
            onActionPressed: () => AppRoutes.openStays(context),
          ),
          const SizedBox(height: AppSpacing.md),
          const _StaysPreview(),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeader(
            title: 'Things to do',
            subtitle: 'Guided tours and activities',
            actionLabel: 'See all',
            onActionPressed: () => AppRoutes.openExperiences(context),
          ),
          const SizedBox(height: AppSpacing.md),
          _ExperiencesRail(height: railHeight),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _ServicesRow extends ConsumerWidget {
  const _ServicesRow();

  void _open(BuildContext context, ServiceKind service) {
    switch (service) {
      case ServiceKind.stays:
        AppRoutes.openStays(context);
      case ServiceKind.flights:
        // Opens the dedicated departures board, not Explore.
        AppRoutes.openFlights(context);
      case ServiceKind.experiences:
        AppRoutes.openExperiences(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Row(
        children: <Widget>[
          for (final ServiceKind service in ServiceKind.values) ...<Widget>[
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => _open(context, service),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                      horizontal: AppSpacing.sm,
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          service.icon,
                          size: AppTheme.iconService,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          service.label,
                          style: theme.textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (service != ServiceKind.values.last)
              const SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _AttractionsRail extends ConsumerWidget {
  const _AttractionsRail({required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(cityAttractionsProvider)
        .when(
          loading: () => RailPlaceholder(height: height),
          error:
              (Object error, StackTrace _) => SizedBox(
                height: height,
                child: ErrorView(
                  message: describeCatalogError(error),
                  compact: true,
                  onRetry: () => ref.invalidate(cityAttractionsProvider),
                ),
              ),
          data: (List<Attraction> attractions) {
            if (attractions.isEmpty) {
              return const _EmptySection(
                message: 'No landmarks listed for this city yet.',
              );
            }
            return SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.pageHorizontal,
                itemCount: attractions.length,
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final Attraction attraction = attractions[index];
                  return AttractionCard(
                    attraction: attraction,
                    onTap: () => AppRoutes.showAttraction(context, attraction),
                  );
                },
              ),
            );
          },
        );
  }
}

class _ExperiencesRail extends ConsumerWidget {
  const _ExperiencesRail({required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(cityExperiencesProvider)
        .when(
          loading: () => RailPlaceholder(height: height),
          error:
              (Object error, StackTrace _) => SizedBox(
                height: height,
                child: ErrorView(
                  message: describeCatalogError(error),
                  compact: true,
                  onRetry: () => ref.invalidate(cityExperiencesProvider),
                ),
              ),
          data: (List<Experience> experiences) {
            if (experiences.isEmpty) {
              return const _EmptySection(
                message: 'No activities listed for this city yet.',
              );
            }
            return SizedBox(
              height: height,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.pageHorizontal,
                itemCount: experiences.length,
                separatorBuilder:
                    (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final Experience experience = experiences[index];
                  return ExperienceCard(
                    experience: experience,
                    onTap: () => AppRoutes.openExperience(context, experience),
                  );
                },
              ),
            );
          },
        );
  }
}

class _StaysPreview extends ConsumerWidget {
  const _StaysPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(cityHotelsProvider)
        .when(
          loading: () => const RailPlaceholder(height: 180),
          error:
              (Object error, StackTrace _) => ErrorView(
                message: describeCatalogError(error),
                compact: true,
                onRetry: () => ref.invalidate(cityHotelsProvider),
              ),
          data: (List<Hotel> hotels) {
            if (hotels.isEmpty) {
              return const _EmptySection(
                message: 'No stays listed for this city yet.',
              );
            }
            final List<Hotel> preview = hotels.take(2).toList();
            return Padding(
              padding: AppSpacing.pageHorizontal,
              child: Column(
                children: <Widget>[
                  for (final Hotel hotel in preview) ...<Widget>[
                    HotelCard(
                      hotel: hotel,
                      onTap: () => AppRoutes.openHotel(context, hotel),
                    ),
                    if (hotel != preview.last)
                      const SizedBox(height: AppSpacing.lg),
                  ],
                ],
              ),
            );
          },
        );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
