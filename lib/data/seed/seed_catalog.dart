import '../models/amenity.dart';
import '../models/attraction.dart';
import '../models/destination.dart';
import '../models/experience.dart';
import '../models/hotel.dart';
import '../models/payment_card.dart';
import '../models/place_category.dart';
import '../models/trip_offer.dart';

/// The catalogue the app ships with.
///
/// This is the single source of the content that used to be duplicated as
/// inline `List<Map<String, dynamic>>` literals inside the screen widgets.
/// When a backend exists, only the repositories need to change — nothing here
/// leaks into the UI layer.
abstract final class SeedCatalog {
  /// Where the traveller departs from.
  static const String originCity = 'Algiers';
  static const String originCode = 'ALG';

  /// The city the home feed is currently showing.
  static const String browsingCity = 'New York';
  static const String browsingCountry = 'USA';

  static const String emptyFavouritesImage = 'assets/images/no_favourites.jpg';
  static const String welcomeImage = 'assets/images/background.jpg';
  static const String logoImage = 'assets/images/gotrek_logo.png';

  /// Dates are generated relative to [now] so the app never shows a trip that
  /// has already departed.
  static List<Destination> destinations({DateTime? now}) {
    final DateTime base = _startOfDay(now ?? DateTime.now());

    return <Destination>[
      Destination(
        id: 'paris',
        city: 'Paris',
        country: 'France',
        imageAsset: 'assets/images/paris_explore.jpg',
        distanceKm: 1351,
        rating: 4.8,
        summary:
            'Boulevards, riverside walks and the best museum mile in Europe. '
            'Short hop from Algiers, easy to do over a long weekend.',
        categories: <PlaceCategory>[PlaceCategory.city],
        trip: _returnTrip(
          base: base,
          departsInDays: 14,
          toCity: 'Paris',
          toCode: 'CDG',
          outboundHour: 8,
          flightMinutes: 155,
          stayNights: 4,
          returnHour: 18,
          price: 189,
          cabin: 'Economy',
          seatsLeft: 12,
          flightNumber: 'GT 218',
          returnFlightNumber: 'GT 219',
        ),
      ),
      Destination(
        id: 'moscow',
        city: 'Moscow',
        country: 'Russia',
        imageAsset: 'assets/images/russia_explore.jpg',
        distanceKm: 3318,
        rating: 4.5,
        summary:
            'Red Square, the metro palaces and birch forest on the city edge. '
            'Best paired with a few days outside the ring road.',
        categories: <PlaceCategory>[PlaceCategory.city, PlaceCategory.forest],
        trip: _returnTrip(
          base: base,
          departsInDays: 26,
          toCity: 'Moscow',
          toCode: 'SVO',
          outboundHour: 9,
          flightMinutes: 300,
          stayNights: 6,
          returnHour: 14,
          price: 264,
          cabin: 'Economy',
          seatsLeft: 6,
          flightNumber: 'GT 440',
          returnFlightNumber: 'GT 441',
        ),
      ),
      Destination(
        id: 'toronto',
        city: 'Toronto',
        country: 'Canada',
        imageAsset: 'assets/images/toronto_canada.jpg',
        distanceKm: 6598,
        rating: 4.6,
        summary:
            'Lakefront city with Algonquin canoe country and dense pine forest '
            'a few hours north. Good base for a mixed city and outdoors trip.',
        categories: <PlaceCategory>[
          PlaceCategory.city,
          PlaceCategory.lakes,
          PlaceCategory.forest,
          PlaceCategory.camp,
        ],
        trip: _returnTrip(
          base: base,
          departsInDays: 21,
          toCity: 'Toronto',
          toCode: 'YYZ',
          outboundHour: 11,
          flightMinutes: 555,
          stayNights: 5,
          returnHour: 16,
          price: 542,
          cabin: 'Economy',
          seatsLeft: 9,
          flightNumber: 'GT 802',
          returnFlightNumber: 'GT 803',
        ),
      ),
      Destination(
        id: 'new-york',
        city: 'New York',
        country: 'USA',
        imageAsset: 'assets/images/new_york_explore.jpg',
        distanceKm: 6704,
        rating: 4.9,
        summary:
            'Five boroughs, a beach at the end of the subway line and more to '
            'see than one trip allows. The most booked city on GoTrek.',
        categories: <PlaceCategory>[PlaceCategory.city, PlaceCategory.beach],
        trip: _returnTrip(
          base: base,
          departsInDays: 18,
          toCity: 'New York',
          toCode: 'JFK',
          outboundHour: 10,
          flightMinutes: 570,
          stayNights: 5,
          returnHour: 19,
          price: 578,
          cabin: 'Economy',
          seatsLeft: 4,
          flightNumber: 'GT 106',
          returnFlightNumber: 'GT 107',
        ),
      ),
      Destination(
        id: 'tokyo',
        city: 'Tokyo',
        country: 'Japan',
        imageAsset: 'assets/images/tokyo_explore.jpg',
        distanceKm: 11304,
        rating: 4.9,
        summary:
            'Neon districts at street level and Hakone trailheads two hours '
            'out. The longest flight on the list and worth every hour.',
        categories: <PlaceCategory>[
          PlaceCategory.city,
          PlaceCategory.mountains,
        ],
        trip: _returnTrip(
          base: base,
          departsInDays: 34,
          toCity: 'Tokyo',
          toCode: 'HND',
          outboundHour: 7,
          flightMinutes: 900,
          stayNights: 8,
          returnHour: 10,
          price: 894,
          cabin: 'Economy',
          seatsLeft: 15,
          flightNumber: 'GT 550',
          returnFlightNumber: 'GT 551',
        ),
      ),
    ];
  }

  static List<Hotel> hotels() => const <Hotel>[
    Hotel(
      id: 'the-plaza',
      destinationId: 'new-york',
      name: 'The Plaza Hotel',
      area: 'Midtown Manhattan',
      city: 'New York',
      imageAsset: 'assets/images/the_plaza_hotel.jpg',
      rating: 4.9,
      reviewCount: 1200,
      pricePerNight: 250,
      description:
          'A landmark luxury hotel on the western side of Grand Army Plaza, '
          'built in 1907 and facing Central Park across Fifth Avenue. Known '
          'for its elegant design and its place in the city\'s history.',
      amenities: <Amenity>[
        Amenity.wifi,
        Amenity.pool,
        Amenity.breakfast,
        Amenity.gym,
        Amenity.spa,
        Amenity.restaurant,
        Amenity.concierge,
      ],
    ),
    Hotel(
      id: 'ritz-carlton-central-park',
      destinationId: 'new-york',
      name: 'The Ritz-Carlton, Central Park',
      area: 'Midtown Manhattan',
      city: 'New York',
      imageAsset: 'assets/images/ritz_carlton_central_park.jpg',
      rating: 4.8,
      reviewCount: 950,
      pricePerNight: 300,
      description:
          'Overlooking Central Park, three minutes from the subway and five '
          'from Carnegie Hall. Rooms have Italian marble bathrooms and park '
          'views, with the service the address implies.',
      amenities: <Amenity>[
        Amenity.wifi,
        Amenity.gym,
        Amenity.restaurant,
        Amenity.concierge,
        Amenity.roomService,
        Amenity.bar,
      ],
    ),
    Hotel(
      id: 'baccarat',
      destinationId: 'new-york',
      name: 'Baccarat Hotel New York',
      area: 'Midtown Manhattan',
      city: 'New York',
      imageAsset: 'assets/images/baccarat_hotel.jpg',
      rating: 4.9,
      reviewCount: 780,
      pricePerNight: 350,
      description:
          'Across the street from the Museum of Modern Art, eight minutes '
          'from Central Park. Floor-to-ceiling windows, custom furnishings '
          'and Baccarat crystal throughout.',
      amenities: <Amenity>[
        Amenity.wifi,
        Amenity.pool,
        Amenity.bar,
        Amenity.roomService,
        Amenity.spa,
        Amenity.gym,
      ],
    ),
    Hotel(
      id: 'the-peninsula',
      destinationId: 'new-york',
      name: 'The Peninsula New York',
      area: 'Fifth Avenue',
      city: 'New York',
      imageAsset: 'assets/images/the_peninsula_hotel.jpg',
      rating: 4.7,
      reviewCount: 1100,
      pricePerNight: 280,
      description:
          'A grand Midtown hotel three minutes from the 53rd Street subway '
          'and nine from Central Park. Marble bathrooms, a rooftop pool and '
          'a reputation for getting the details right.',
      amenities: <Amenity>[
        Amenity.wifi,
        Amenity.spa,
        Amenity.pool,
        Amenity.gym,
        Amenity.restaurant,
        Amenity.bar,
      ],
    ),
    Hotel(
      id: 'the-carlyle',
      destinationId: 'new-york',
      name: 'The Carlyle, A Rosewood Hotel',
      area: 'Upper East Side',
      city: 'New York',
      imageAsset: 'assets/images/the_carlyle_hotel.jpg',
      rating: 4.8,
      reviewCount: 850,
      pricePerNight: 320,
      description:
          'An Upper East Side institution three minutes from the 77th Street '
          'subway and twelve from the Met. Classic New York glamour, and '
          'discreet about it.',
      amenities: <Amenity>[
        Amenity.wifi,
        Amenity.gym,
        Amenity.bar,
        Amenity.roomService,
        Amenity.spa,
        Amenity.restaurant,
      ],
    ),
  ];

  static List<Attraction> attractions() => const <Attraction>[
    Attraction(
      id: 'empire-state-building',
      destinationId: 'new-york',
      name: 'Empire State Building',
      area: 'Manhattan, New York',
      imageAsset: 'assets/images/empire_state_building.jpg',
      rating: 4.8,
      reviewCount: 9400,
    ),
    Attraction(
      id: 'coney-island-beach',
      destinationId: 'new-york',
      name: 'Coney Island Beach',
      area: 'Brooklyn, New York',
      imageAsset: 'assets/images/coney_island_beach.jpg',
      rating: 4.3,
      reviewCount: 5100,
    ),
    Attraction(
      id: 'yankee-stadium',
      destinationId: 'new-york',
      name: 'Yankee Stadium',
      area: 'The Bronx, New York',
      imageAsset: 'assets/images/yankee_stadium.jpg',
      rating: 4.6,
      reviewCount: 7300,
    ),
  ];

  static List<Experience> experiences({DateTime? now}) {
    final DateTime base = _startOfDay(now ?? DateTime.now());

    return <Experience>[
      Experience(
        id: 'statue-of-liberty-tour',
        destinationId: 'new-york',
        name: 'Statue of Liberty Tour',
        area: 'Liberty Island, New York',
        imageAsset: 'assets/images/statue_of_liberty_tour.jpg',
        rating: 4.7,
        reviewCount: 2100,
        price: 32,
        duration: const Duration(hours: 3),
        startsAt: base.add(const Duration(days: 3, hours: 9)),
        description:
            'Ferry from Battery Park with a guide, pedestal access and time '
            'on Ellis Island on the way back.',
      ),
      Experience(
        id: 'brooklyn-bridge-walk',
        destinationId: 'new-york',
        name: 'Brooklyn Bridge Walk',
        area: 'Brooklyn, New York',
        imageAsset: 'assets/images/brooklyn_bridge_walk.jpg',
        rating: 4.6,
        reviewCount: 1450,
        price: 18,
        duration: const Duration(hours: 2),
        startsAt: base.add(const Duration(days: 4, hours: 16)),
        description:
            'Guided crossing from City Hall to DUMBO timed for sunset, '
            'finishing at the waterfront.',
      ),
      Experience(
        id: 'central-park-bike-ride',
        destinationId: 'new-york',
        name: 'Central Park Bike Ride',
        area: 'Manhattan, New York',
        imageAsset: 'assets/images/central_park_bike_ride.jpg',
        rating: 4.8,
        reviewCount: 1830,
        price: 25,
        duration: const Duration(hours: 4),
        startsAt: base.add(const Duration(days: 5, hours: 10)),
        description:
            'Bike hire, helmet and a loop of the park with stops at the '
            'Reservoir, Bethesda Terrace and the Ramble.',
      ),
    ];
  }

  static List<PaymentCard> paymentCards() => const <PaymentCard>[
    PaymentCard(
      id: 'card-visa',
      brand: CardBrand.visa,
      last4: '1234',
      holderName: 'C. KANNOUFI',
      expiryMonth: 8,
      expiryYear: 2029,
    ),
    PaymentCard(
      id: 'card-mastercard',
      brand: CardBrand.mastercard,
      last4: '5678',
      holderName: 'C. KANNOUFI',
      expiryMonth: 3,
      expiryYear: 2028,
    ),
  ];

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static TripOffer _returnTrip({
    required DateTime base,
    required int departsInDays,
    required String toCity,
    required String toCode,
    required int outboundHour,
    required int flightMinutes,
    required int stayNights,
    required int returnHour,
    required double price,
    required String cabin,
    required int seatsLeft,
    required String flightNumber,
    required String returnFlightNumber,
  }) {
    final DateTime outboundDeparture = base.add(
      Duration(days: departsInDays, hours: outboundHour),
    );
    final DateTime inboundDeparture = base.add(
      Duration(days: departsInDays + stayNights, hours: returnHour),
    );

    return TripOffer(
      outbound: FlightLeg(
        fromCity: originCity,
        fromCode: originCode,
        toCity: toCity,
        toCode: toCode,
        departsAt: outboundDeparture,
        arrivesAt: outboundDeparture.add(Duration(minutes: flightMinutes)),
        flightNumber: flightNumber,
      ),
      inbound: FlightLeg(
        fromCity: toCity,
        fromCode: toCode,
        toCity: originCity,
        toCode: originCode,
        departsAt: inboundDeparture,
        arrivesAt: inboundDeparture.add(Duration(minutes: flightMinutes)),
        flightNumber: returnFlightNumber,
      ),
      pricePerTraveller: price,
      cabin: cabin,
      seatsLeft: seatsLeft,
    );
  }
}
