import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/cards/rail_cards.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/experience.dart';
import '../../state/catalog_providers.dart';

class ExperiencesScreen extends ConsumerWidget {
  const ExperiencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experiences')),
      body: ref
          .watch(experiencesProvider)
          .when(
            loading: () => const LoadingView(),
            error:
                (Object error, StackTrace _) => ErrorView(
                  message: describeCatalogError(error),
                  onRetry: () => ref.invalidate(experiencesProvider),
                ),
            data: (List<Experience> experiences) {
              if (experiences.isEmpty) {
                return const EmptyView(
                  title: 'No experiences listed',
                  message: 'Check back once tours have been published.',
                  icon: Icons.hiking_outlined,
                );
              }

              return RefreshIndicator(
                onRefresh: () => refreshCatalog(ref),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 268,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: experiences.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Experience experience = experiences[index];
                    return ExperienceCard(
                      experience: experience,
                      width: double.infinity,
                      onTap:
                          () => AppRoutes.openExperience(context, experience),
                    );
                  },
                ),
              );
            },
          ),
    );
  }
}
