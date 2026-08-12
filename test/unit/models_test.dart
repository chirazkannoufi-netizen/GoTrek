import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/data/models/booking.dart';
import 'package:gotrek_app/data/models/booking_draft.dart';
import 'package:gotrek_app/data/models/catalog_item.dart';
import 'package:gotrek_app/data/models/destination.dart';
import 'package:gotrek_app/data/models/hotel.dart';
import 'package:gotrek_app/data/seed/seed_catalog.dart';

void main() {
  group('FavoriteRef', () {
    test('round-trips through its encoded form', () {
      const FavoriteRef ref = FavoriteRef(SavedKind.hotel, 'the-plaza');
      expect(ref.encode(), 'hotel:the-plaza');
      expect(FavoriteRef.decode(ref.encode()), ref);
    });

    test('handles ids that contain a colon', () {
      const FavoriteRef ref = FavoriteRef(SavedKind.destination, 'a:b');
      expect(FavoriteRef.decode(ref.encode()), ref);
    });

    test('returns null for malformed input', () {
      expect(FavoriteRef.decode('nonsense'), isNull);
      expect(FavoriteRef.decode('unknownkind:1'), isNull);
      expect(FavoriteRef.decode('hotel:'), isNull);
    });

    test('deduplicates by value, so it works as a set key', () {
      // Decoded separately, these are distinct instances that must still
      // collapse to one entry — this is what keeps the saved list unique.
      final Set<FavoriteRef> refs = <String>['hotel:x', 'hotel:x']
          .map(FavoriteRef.decode)
          .whereType<FavoriteRef>()
          .toSet();

      expect(refs, hasLength(1));
    });
  });

  group('Hotel', () {
    final Hotel hotel = SeedCatalog.hotels().first;

    test('multiplies nights by rooms', () {
      expect(hotel.totalFor(nights: 3, rooms: 2), hotel.pricePerNight * 6);
    });

    test('matches on name and area, case-insensitively', () {
      expect(hotel.matches('plaza'), isTrue);
      expect(hotel.matches('MIDTOWN'), isTrue);
      expect(hotel.matches('reykjavik'), isFalse);
      expect(hotel.matches(''), isTrue);
    });
  });

  group('Destination', () {
    final List<Destination> destinations = SeedCatalog.destinations(
      now: DateTime(2026, 1, 15),
    );

    test('every trip departs in the future relative to the seed date', () {
      for (final Destination destination in destinations) {
        expect(
          destination.trip.outbound.departsAt.isAfter(DateTime(2026, 1, 15)),
          isTrue,
          reason: '${destination.city} departs in the past',
        );
      }
    });

    test('the return leg comes back to the origin', () {
      for (final Destination destination in destinations) {
        expect(destination.trip.inbound.toCode, SeedCatalog.originCode);
      }
    });

    test('title combines city and country', () {
      expect(destinations.first.title, contains(destinations.first.city));
      expect(destinations.first.title, contains(destinations.first.country));
    });
  });

  group('BookingDraft', () {
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

    test('totals the line items and adds the service fee', () {
      expect(draft.subtotal, 750);
      expect(draft.serviceFee, 60);
      expect(draft.total, 810);
    });

    test('derives the night count from the dates', () {
      expect(draft.nights, 3);
    });
  });

  group('Booking', () {
    test('survives a JSON round-trip', () {
      final Booking booking = Booking(
        id: 'booking-1',
        reference: 'GT-7KQ4M2',
        kind: BookingKind.trip,
        title: 'Tokyo, Japan',
        subtitle: 'Return from Algiers',
        imageAsset: 'assets/images/tokyo_explore.jpg',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 9),
        guests: 2,
        total: 1930.4,
        status: BookingStatus.confirmed,
        createdAt: DateTime(2026, 1, 15, 10, 30),
        paymentLabel: 'Visa •••• 1234',
      );

      final Booking restored = Booking.fromJson(booking.toJson());

      expect(restored.reference, booking.reference);
      expect(restored.kind, booking.kind);
      expect(restored.status, booking.status);
      expect(restored.total, booking.total);
      expect(restored.startDate, booking.startDate);
      expect(restored.guests, booking.guests);
    });

    test('falls back rather than throwing on an unknown enum name', () {
      final Booking booking = Booking.fromJson(<String, dynamic>{
        'id': 'x',
        'reference': 'GT-X',
        'kind': 'not-a-kind',
        'title': 't',
        'subtitle': 's',
        'imageAsset': '',
        'startDate': '2026-03-01T00:00:00.000',
        'endDate': '2026-03-02T00:00:00.000',
        'guests': 1,
        'total': 10,
        'status': 'not-a-status',
        'createdAt': '2026-01-15T00:00:00.000',
        'paymentLabel': 'Visa',
      });

      expect(booking.kind, BookingKind.stay);
      expect(booking.status, BookingStatus.confirmed);
    });
  });
}
