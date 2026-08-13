import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/attraction.dart';
import '../data/models/catalog_item.dart';
import '../data/models/city_location.dart';
import '../data/models/daily_flight.dart';
import '../data/models/destination.dart';
import '../data/models/experience.dart';
import '../data/models/hotel.dart';
import '../data/models/payment_card.dart';
import '../data/models/place_category.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/seed/seed_catalog.dart';
import 'repository_providers.dart';

final FutureProvider<List<Destination>> destinationsProvider =
    FutureProvider<List<Destination>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).destinations(),
    );

final FutureProvider<List<Hotel>> hotelsProvider = FutureProvider<List<Hotel>>(
  (Ref ref) => ref.watch(catalogRepositoryProvider).hotels(),
);

final FutureProvider<List<Attraction>> attractionsProvider =
    FutureProvider<List<Attraction>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).attractions(),
    );

final FutureProvider<List<Experience>> experiencesProvider =
    FutureProvider<List<Experience>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).experiences(),
    );

final FutureProvider<List<PaymentCard>> paymentCardsProvider =
    FutureProvider<List<PaymentCard>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).paymentCards(),
    );

final FutureProviderFamily<Hotel, String> hotelByIdProvider =
    FutureProvider.family<Hotel, String>(
      (Ref ref, String id) =>
          ref.watch(catalogRepositoryProvider).hotelById(id),
    );

final FutureProviderFamily<Destination, String> destinationByIdProvider =
    FutureProvider.family<Destination, String>(
      (Ref ref, String id) =>
          ref.watch(catalogRepositoryProvider).destinationById(id),
    );

/// Hotels for one destination, used by the "stays in this city" section.
final FutureProviderFamily<List<Hotel>, String> hotelsForDestinationProvider =
    FutureProvider.family<List<Hotel>, String>(
      (Ref ref, String destinationId) => ref
          .watch(catalogRepositoryProvider)
          .hotels(destinationId: destinationId),
    );

// ---------------------------------------------------------------------------
// Current city
// ---------------------------------------------------------------------------

/// The city the home screen is showing. Changed through the location picker.
class CurrentCityController extends Notifier<CityLocation> {
  @override
  CityLocation build() => SeedCatalog.currentCity;

  void select(CityLocation city) => state = city;
}

final NotifierProvider<CurrentCityController, CityLocation>
currentCityProvider = NotifierProvider<CurrentCityController, CityLocation>(
  CurrentCityController.new,
);

final FutureProvider<List<CityLocation>> selectableCitiesProvider =
    FutureProvider<List<CityLocation>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).selectableCities(),
    );

/// Stays, places and things to do in the current city — the home feed.
final FutureProvider<List<Hotel>> cityHotelsProvider =
    FutureProvider<List<Hotel>>((Ref ref) {
      final CityLocation city = ref.watch(currentCityProvider);
      return ref
          .watch(catalogRepositoryProvider)
          .hotels(destinationId: city.id);
    });

final FutureProvider<List<Attraction>> cityAttractionsProvider =
    FutureProvider<List<Attraction>>((Ref ref) {
      final CityLocation city = ref.watch(currentCityProvider);
      return ref.watch(catalogRepositoryProvider).attractions(cityId: city.id);
    });

final FutureProvider<List<Experience>> cityExperiencesProvider =
    FutureProvider<List<Experience>>((Ref ref) {
      final CityLocation city = ref.watch(currentCityProvider);
      return ref.watch(catalogRepositoryProvider).experiences(cityId: city.id);
    });

// ---------------------------------------------------------------------------
// Home search — stays and places in the current city, never a redirect
// ---------------------------------------------------------------------------

class HomeSearchController extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;

  void clear() => state = '';
}

final NotifierProvider<HomeSearchController, String> homeSearchProvider =
    NotifierProvider<HomeSearchController, String>(HomeSearchController.new);

/// Hotels, places and activities in the current city matching the home
/// search box. Empty query yields an empty list — the feed is shown instead.
final Provider<AsyncValue<List<CatalogItem>>> homeSearchResultsProvider =
    Provider<AsyncValue<List<CatalogItem>>>((Ref ref) {
      final String query = ref.watch(homeSearchProvider).trim();
      if (query.isEmpty) {
        return const AsyncValue<List<CatalogItem>>.data(<CatalogItem>[]);
      }

      final AsyncValue<List<Hotel>> hotels = ref.watch(cityHotelsProvider);
      final AsyncValue<List<Attraction>> attractions = ref.watch(
        cityAttractionsProvider,
      );
      final AsyncValue<List<Experience>> experiences = ref.watch(
        cityExperiencesProvider,
      );

      if (hotels.isLoading || attractions.isLoading || experiences.isLoading) {
        return const AsyncValue<List<CatalogItem>>.loading();
      }
      final Object? error =
          hotels.error ?? attractions.error ?? experiences.error;
      if (error != null) {
        return AsyncValue<List<CatalogItem>>.error(error, StackTrace.current);
      }

      return AsyncValue<List<CatalogItem>>.data(<CatalogItem>[
        ...?hotels.value?.where((Hotel h) => h.matches(query)),
        ...?attractions.value?.where((Attraction a) => a.matches(query)),
        ...?experiences.value?.where((Experience e) => e.matches(query)),
      ]);
    });

// ---------------------------------------------------------------------------
// Flights leaving today
// ---------------------------------------------------------------------------

final FutureProvider<List<DailyFlight>> dailyFlightsProvider =
    FutureProvider<List<DailyFlight>>(
      (Ref ref) => ref.watch(catalogRepositoryProvider).dailyFlights(),
    );

// ---------------------------------------------------------------------------
// Explore filters
// ---------------------------------------------------------------------------

class ExploreFilter {
  const ExploreFilter({this.query = '', this.category});

  final String query;
  final PlaceCategory? category;

  bool get isActive => query.trim().isNotEmpty || category != null;

  ExploreFilter copyWith({
    String? query,
    PlaceCategory? category,
    bool clearCategory = false,
  }) => ExploreFilter(
    query: query ?? this.query,
    category: clearCategory ? null : (category ?? this.category),
  );
}

class ExploreFilterNotifier extends Notifier<ExploreFilter> {
  @override
  ExploreFilter build() => const ExploreFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Tapping the selected chip again clears the filter.
  void toggleCategory(PlaceCategory category) {
    state =
        state.category == category
            ? state.copyWith(clearCategory: true)
            : state.copyWith(category: category);
  }

  void selectCategory(PlaceCategory? category) =>
      state =
          category == null
              ? state.copyWith(clearCategory: true)
              : state.copyWith(category: category);

  void clear() => state = const ExploreFilter();
}

final NotifierProvider<ExploreFilterNotifier, ExploreFilter>
exploreFilterProvider = NotifierProvider<ExploreFilterNotifier, ExploreFilter>(
  ExploreFilterNotifier.new,
);

final Provider<AsyncValue<List<Destination>>> filteredDestinationsProvider =
    Provider<AsyncValue<List<Destination>>>((Ref ref) {
      final ExploreFilter filter = ref.watch(exploreFilterProvider);
      return ref
          .watch(destinationsProvider)
          .whenData(
            (List<Destination> all) =>
                all.where((Destination destination) {
                  final bool categoryOk =
                      filter.category == null ||
                      destination.categories.contains(filter.category);
                  return categoryOk && destination.matches(filter.query);
                }).toList(),
          );
    });

// ---------------------------------------------------------------------------
// Stays filters
// ---------------------------------------------------------------------------

class StaysFilter {
  const StaysFilter({this.query = '', this.sort = HotelSort.priceLowToHigh});

  final String query;
  final HotelSort sort;

  StaysFilter copyWith({String? query, HotelSort? sort}) =>
      StaysFilter(query: query ?? this.query, sort: sort ?? this.sort);
}

class StaysFilterNotifier extends Notifier<StaysFilter> {
  @override
  StaysFilter build() => const StaysFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setSort(HotelSort sort) => state = state.copyWith(sort: sort);
}

final NotifierProvider<StaysFilterNotifier, StaysFilter> staysFilterProvider =
    NotifierProvider<StaysFilterNotifier, StaysFilter>(StaysFilterNotifier.new);

final Provider<AsyncValue<List<Hotel>>> filteredHotelsProvider =
    Provider<AsyncValue<List<Hotel>>>((Ref ref) {
      final StaysFilter filter = ref.watch(staysFilterProvider);
      return ref.watch(hotelsProvider).whenData((List<Hotel> all) {
        final List<Hotel> matched =
            all.where((Hotel hotel) => hotel.matches(filter.query)).toList();
        final Comparator<Hotel> comparator = switch (filter.sort) {
          HotelSort.priceLowToHigh =>
            (Hotel a, Hotel b) => a.pricePerNight.compareTo(b.pricePerNight),
          HotelSort.priceHighToLow =>
            (Hotel a, Hotel b) => b.pricePerNight.compareTo(a.pricePerNight),
          HotelSort.topRated =>
            (Hotel a, Hotel b) => b.rating.compareTo(a.rating),
        };
        matched.sort(comparator);
        return matched;
      });
    });

/// Re-reads every catalogue collection. Wired to pull-to-refresh.
Future<void> refreshCatalog(WidgetRef ref) async {
  ref.invalidate(destinationsProvider);
  ref.invalidate(hotelsProvider);
  ref.invalidate(attractionsProvider);
  ref.invalidate(experiencesProvider);
  await Future.wait(<Future<Object?>>[
    ref.read(destinationsProvider.future),
    ref.read(hotelsProvider.future),
    ref.read(attractionsProvider.future),
    ref.read(experiencesProvider.future),
  ]);
}

/// Exposed so screens can surface a readable message for a failed load.
String describeCatalogError(Object error) =>
    error is CatalogNotFoundException
        ? error.message
        : 'Something went wrong while loading. Please try again.';
