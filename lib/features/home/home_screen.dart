import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/cards/hotel_card.dart';
import '../../core/widgets/cards/rail_cards.dart';
import '../../core/widgets/category_chips.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/attraction.dart';
import '../../data/models/experience.dart';
import '../../data/models/hotel.dart';
import '../../data/models/place_category.dart';
import '../../data/seed/seed_catalog.dart';
import '../../state/auth_controller.dart';
import '../../state/catalog_providers.dart';
import '../../state/navigation_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _railHeight = 268;

  void _goToExplore(WidgetRef ref, {PlaceCategory? category}) {
    if (category != null) {
      ref.read(exploreFilterProvider.notifier).selectCategory(category);
    }
    ref.read(navigationProvider.notifier).select(AppTab.explore);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlaceCategory? selectedCategory = ref.watch(
      exploreFilterProvider.select((ExploreFilter filter) => filter.category),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => refreshCatalog(ref),
        child: CustomScrollView(
          slivers: <Widget>[
            const _HomeAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  CategoryChips(
                    selected: selectedCategory,
                    onSelected:
                        (PlaceCategory category) =>
                            _goToExplore(ref, category: category),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const _ServicesRow(),
                  const SizedBox(height: AppSpacing.xxl),
                  const SectionHeader(
                    title: 'Most visited',
                    subtitle: 'Landmarks travellers rate highest',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _AttractionsRail(height: _railHeight),
                  const SizedBox(height: AppSpacing.xxl),
                  SectionHeader(
                    title: 'Places to stay',
                    subtitle: 'Hand-picked hotels in New York',
                    actionLabel: 'See all',
                    onActionPressed: () => AppRoutes.openStays(context),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _StaysPreview(),
                  const SizedBox(height: AppSpacing.xxl),
                  const SectionHeader(
                    title: 'Top events',
                    subtitle: 'Guided tours and activities',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ExperiencesRail(height: _railHeight),
                  const SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
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
          InkWell(
            borderRadius: AppRadius.allSm,
            onTap:
                () => ref
                    .read(navigationProvider.notifier)
                    .select(AppTab.explore),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${SeedCatalog.browsingCity}, ${SeedCatalog.browsingCountry}',
                  style: theme.textTheme.titleSmall,
                ),
                const Icon(Icons.keyboard_arrow_down, size: 20),
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
          child: SearchFieldButton(
            hintText: 'Search destinations',
            onTap:
                () => ref
                    .read(navigationProvider.notifier)
                    .select(AppTab.explore),
          ),
        ),
      ),
    );
  }
}

class _ServicesRow extends StatelessWidget {
  const _ServicesRow();

  void _open(BuildContext context, WidgetRef ref, ServiceKind service) {
    switch (service) {
      case ServiceKind.stays:
        AppRoutes.openStays(context);
      case ServiceKind.flights:
        ref.read(navigationProvider.notifier).select(AppTab.explore);
      case ServiceKind.experiences:
        AppRoutes.openExperiences(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: AppSpacing.pageHorizontal,
      child: Consumer(
        builder:
            (BuildContext context, WidgetRef ref, Widget? child) => Row(
              children: <Widget>[
                for (final ServiceKind service
                    in ServiceKind.values) ...<Widget>[
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => _open(context, ref, service),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                            horizontal: AppSpacing.sm,
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(
                                service.icon,
                                size: 28,
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
        .watch(attractionsProvider)
        .when(
          loading: () => RailPlaceholder(height: height),
          error:
              (Object error, StackTrace _) => SizedBox(
                height: height,
                child: ErrorView(
                  message: describeCatalogError(error),
                  compact: true,
                  onRetry: () => ref.invalidate(attractionsProvider),
                ),
              ),
          data:
              (List<Attraction> attractions) => SizedBox(
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
                      onTap:
                          () => AppRoutes.showAttraction(context, attraction),
                    );
                  },
                ),
              ),
        );
  }
}

class _ExperiencesRail extends ConsumerWidget {
  const _ExperiencesRail({required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(experiencesProvider)
        .when(
          loading: () => RailPlaceholder(height: height),
          error:
              (Object error, StackTrace _) => SizedBox(
                height: height,
                child: ErrorView(
                  message: describeCatalogError(error),
                  compact: true,
                  onRetry: () => ref.invalidate(experiencesProvider),
                ),
              ),
          data:
              (List<Experience> experiences) => SizedBox(
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
                      onTap:
                          () => AppRoutes.openExperience(context, experience),
                    );
                  },
                ),
              ),
        );
  }
}

class _StaysPreview extends ConsumerWidget {
  const _StaysPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(hotelsProvider)
        .when(
          loading: () => const RailPlaceholder(height: 180),
          error:
              (Object error, StackTrace _) => ErrorView(
                message: describeCatalogError(error),
                compact: true,
                onRetry: () => ref.invalidate(hotelsProvider),
              ),
          data: (List<Hotel> hotels) {
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
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            );
          },
        );
  }
}
