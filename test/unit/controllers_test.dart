import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/data/models/booking.dart';
import 'package:gotrek_app/data/models/booking_draft.dart';
import 'package:gotrek_app/data/models/catalog_item.dart';
import 'package:gotrek_app/data/models/destination.dart';
import 'package:gotrek_app/data/models/hotel.dart';
import 'package:gotrek_app/data/models/place_category.dart';
import 'package:gotrek_app/data/repositories/booking_repository.dart';
import 'package:gotrek_app/data/repositories/catalog_repository.dart';
import 'package:gotrek_app/state/bookings_controller.dart';
import 'package:gotrek_app/state/catalog_providers.dart';
import 'package:gotrek_app/state/favorites_controller.dart';
import 'package:gotrek_app/state/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProviderContainer _container() {
  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      catalogRepositoryProvider.overrideWithValue(
        CatalogRepository(latency: Duration.zero, now: DateTime(2026, 1, 15)),
      ),
      bookingRepositoryProvider.overrideWithValue(
        BookingRepository(random: Random(7)),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('FavoritesController', () {
    test('toggle adds, then removes, and reports which happened', () async {
      final ProviderContainer container = _container();
      await container.read(favoritesControllerProvider.future);
      final FavoritesController controller = container.read(
        favoritesControllerProvider.notifier,
      );

      const FavoriteRef plaza = FavoriteRef(SavedKind.hotel, 'the-plaza');

      expect(await controller.toggle(plaza), isTrue);
      expect(container.read(favoritesCountProvider), 1);
      expect(container.read(isFavoriteProvider(plaza)), isTrue);

      expect(await controller.toggle(plaza), isFalse);
      expect(container.read(favoritesCountProvider), 0);
      expect(container.read(isFavoriteProvider(plaza)), isFalse);
    });

    test('saved refs are reloaded from storage', () async {
      final ProviderContainer first = _container();
      await first.read(favoritesControllerProvider.future);
      await first
          .read(favoritesControllerProvider.notifier)
          .toggle(const FavoriteRef(SavedKind.destination, 'tokyo'));

      final ProviderContainer second = _container();
      final Set<FavoriteRef> restored = await second.read(
        favoritesControllerProvider.future,
      );

      expect(
        restored,
        contains(const FavoriteRef(SavedKind.destination, 'tokyo')),
      );
    });

    test('savedItems resolves refs back into catalogue items', () async {
      final ProviderContainer container = _container();
      await container.read(favoritesControllerProvider.future);
      await container
          .read(favoritesControllerProvider.notifier)
          .toggle(const FavoriteRef(SavedKind.hotel, 'baccarat'));

      final List<CatalogItem> items = await container.read(
        savedItemsProvider.future,
      );

      expect(items, hasLength(1));
      expect(items.single.title, 'Baccarat Hotel New York');
    });

    test('a ref pointing at a removed item is skipped, not fatal', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'gotrek.favorites': <String>['hotel:does-not-exist'],
      });
      final ProviderContainer container = _container();

      final List<CatalogItem> items = await container.read(
        savedItemsProvider.future,
      );

      expect(items, isEmpty);
    });
  });

  group('BookingsController', () {
    final BookingDraft draft = BookingDraft(
      kind: BookingKind.stay,
      title: 'The Plaza Hotel',
      subtitle: 'Midtown Manhattan, New York',
      imageAsset: 'assets/images/the_plaza_hotel.jpg',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 2, 4),
      guests: 1,
      lineItems: const <BookingLineItem>[
        BookingLineItem(label: r'$250 x 3 nights', amount: 750),
      ],
    );

    test('confirm stores the booking with the draft total', () async {
      final ProviderContainer container = _container();
      await container.read(bookingsControllerProvider.future);

      final Booking booking = await container
          .read(bookingsControllerProvider.notifier)
          .confirm(draft: draft, paymentLabel: 'Visa •••• 1234');

      expect(booking.total, draft.total);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.reference, startsWith('GT-'));
      expect(container.read(bookingsControllerProvider).value, hasLength(1));
    });

    test('confirmed bookings persist', () async {
      final ProviderContainer first = _container();
      await first.read(bookingsControllerProvider.future);
      await first
          .read(bookingsControllerProvider.notifier)
          .confirm(draft: draft, paymentLabel: 'Visa •••• 1234');

      final ProviderContainer second = _container();
      final List<Booking> restored = await second.read(
        bookingsControllerProvider.future,
      );

      expect(restored, hasLength(1));
      expect(restored.single.title, 'The Plaza Hotel');
    });

    test('cancel flips the status without dropping the booking', () async {
      final ProviderContainer container = _container();
      await container.read(bookingsControllerProvider.future);
      final BookingsController controller = container.read(
        bookingsControllerProvider.notifier,
      );

      final Booking booking = await controller.confirm(
        draft: draft,
        paymentLabel: 'Visa •••• 1234',
      );
      await controller.cancel(booking.id);

      final List<Booking> bookings =
          container.read(bookingsControllerProvider).value!;
      expect(bookings, hasLength(1));
      expect(bookings.single.status, BookingStatus.cancelled);
    });
  });

  group('catalogue filters', () {
    test('stays sort orders by price and by rating', () async {
      final ProviderContainer container = _container();
      await container.read(hotelsProvider.future);
      final StaysFilterNotifier notifier = container.read(
        staysFilterProvider.notifier,
      );

      notifier.setSort(HotelSort.priceLowToHigh);
      final List<double> ascending =
          container
              .read(filteredHotelsProvider)
              .value!
              .map((Hotel hotel) => hotel.pricePerNight)
              .toList();
      expect(ascending, orderedEquals(<double>[...ascending]..sort()));

      notifier.setSort(HotelSort.priceHighToLow);
      final List<double> descending =
          container
              .read(filteredHotelsProvider)
              .value!
              .map((Hotel hotel) => hotel.pricePerNight)
              .toList();
      expect(descending, orderedEquals(ascending.reversed.toList()));

      notifier.setSort(HotelSort.topRated);
      final List<double> byRating =
          container
              .read(filteredHotelsProvider)
              .value!
              .map((Hotel hotel) => hotel.rating)
              .toList();
      expect(byRating.first, greaterThanOrEqualTo(byRating.last));
    });

    test('stays search narrows the list', () async {
      final ProviderContainer container = _container();
      await container.read(hotelsProvider.future);

      container.read(staysFilterProvider.notifier).setQuery('carlyle');

      final List<Hotel> results = container.read(filteredHotelsProvider).value!;
      expect(results, hasLength(1));
      expect(results.single.name, 'The Carlyle, A Rosewood Hotel');
    });

    test('explore category filter keeps only tagged destinations', () async {
      final ProviderContainer container = _container();
      await container.read(destinationsProvider.future);

      container
          .read(exploreFilterProvider.notifier)
          .selectCategory(PlaceCategory.beach);

      final List<Destination> results =
          container.read(filteredDestinationsProvider).value!;
      expect(results.map((Destination d) => d.id), <String>[
        'bangkok',
        'dubai',
        'barcelona',
      ]);
    });

    test('tapping the selected category again clears it', () async {
      final ProviderContainer container = _container();
      await container.read(destinationsProvider.future);
      final ExploreFilterNotifier notifier = container.read(
        exploreFilterProvider.notifier,
      );

      notifier.toggleCategory(PlaceCategory.beach);
      expect(container.read(exploreFilterProvider).category, isNotNull);

      notifier.toggleCategory(PlaceCategory.beach);
      expect(container.read(exploreFilterProvider).category, isNull);
    });

    test('a search with no match yields an empty list, not an error', () async {
      final ProviderContainer container = _container();
      await container.read(destinationsProvider.future);

      container.read(exploreFilterProvider.notifier).setQuery('atlantis');

      final AsyncValue<List<Destination>> result = container.read(
        filteredDestinationsProvider,
      );
      expect(result.hasError, isFalse);
      expect(result.value, isEmpty);
    });
  });
}
