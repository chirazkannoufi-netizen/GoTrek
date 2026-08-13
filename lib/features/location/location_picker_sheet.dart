import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/city_location.dart';
import '../../state/catalog_providers.dart';

/// "Choose your location" — opened from the home app bar.
///
/// Only cities the catalogue has content for are selectable; the rest are
/// shown greyed out rather than hidden, so the control does not look broken.
class LocationPickerSheet extends ConsumerWidget {
  const LocationPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final CityLocation current = ref.watch(currentCityProvider);
    final AsyncValue<List<CityLocation>> cities = ref.watch(
      selectableCitiesProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Choose your location',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Home shows the stays, places and activities around you.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            cities.when(
              loading:
                  () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: LoadingView(),
                  ),
              error:
                  (Object error, StackTrace _) => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: ErrorView(
                      message: 'Could not load locations.',
                      compact: true,
                    ),
                  ),
              data:
                  (List<CityLocation> available) => Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CityLocation city = available[index];
                        final bool selected = city.id == current.id;

                        return ListTile(
                          enabled: city.isAvailable,
                          leading: Icon(
                            selected
                                ? Icons.my_location
                                : Icons.location_on_outlined,
                            color: selected ? theme.colorScheme.primary : null,
                          ),
                          title: Text(city.label),
                          subtitle:
                              city.isAvailable
                                  ? Text(
                                    '${city.airportCode} · content available',
                                  )
                                  : const Text('Not available yet'),
                          trailing:
                              selected
                                  ? Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.primary,
                                  )
                                  : null,
                          onTap:
                              city.isAvailable
                                  ? () {
                                    ref
                                        .read(currentCityProvider.notifier)
                                        .select(city);
                                    Navigator.of(context).pop();
                                  }
                                  : null,
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
