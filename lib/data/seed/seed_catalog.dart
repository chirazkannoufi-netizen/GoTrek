import '../models/amenity.dart';
import '../models/attraction.dart';
import '../models/city_location.dart';
import '../models/daily_flight.dart';
import '../models/destination.dart';
import '../models/experience.dart';
import '../models/hotel.dart';
import '../models/payment_card.dart';
import '../models/place_category.dart';
import '../models/trip_offer.dart';

/// The catalogue the app ships with.
///
/// Two distinct bodies of content:
///  * the **current city** (New York) — the stays, places and activities the
///    home screen shows, all tagged with [currentCity]'s id;
///  * **destinations** — the most-visited cities elsewhere in the world, which
///    Explore lets you search and book a trip to.
///
/// Keeping them separate is what stops Home and Explore being the same list.
abstract final class SeedCatalog {
  /// Where the user is, and therefore where flights depart from.
  static const CityLocation currentCity = CityLocation(
    id: 'new-york',
    city: 'New York',
    country: 'USA',
    airportCode: 'JFK',
    isAvailable: true,
    imageAsset: 'assets/images/new_york_explore.jpg',
  );

  /// Offered by the location picker. Only [currentCity] has local content;
  /// the others are listed so the control is honest about its limits.
  static List<CityLocation> selectableCities() => const <CityLocation>[
    currentCity,
    CityLocation(
      id: 'london',
      city: 'London',
      country: 'United Kingdom',
      airportCode: 'LHR',
      isAvailable: false,
    ),
    CityLocation(
      id: 'paris',
      city: 'Paris',
      country: 'France',
      airportCode: 'CDG',
      isAvailable: false,
    ),
    CityLocation(
      id: 'dubai',
      city: 'Dubai',
      country: 'United Arab Emirates',
      airportCode: 'DXB',
      isAvailable: false,
    ),
    CityLocation(
      id: 'tokyo',
      city: 'Tokyo',
      country: 'Japan',
      airportCode: 'HND',
      isAvailable: false,
    ),
  ];

  static const String emptyFavouritesImage = 'assets/images/no_favourites.jpg';
  static const String welcomeImage = 'assets/images/background.jpg';
  static const String logoImage = 'assets/images/gotrek_logo.png';

  // ---------------------------------------------------------------------------
  // Explore: trips to other cities
  // ---------------------------------------------------------------------------

  /// The most-visited cities travellers fly to, excluding [currentCity].
  ///
  /// Dates are generated relative to [now] so nothing is advertised in the
  /// past. Cities with no photograph in `assets/` carry an empty
  /// `imageAsset`; the destination cards draw a generated cover for those
  /// rather than showing a broken image.
  static List<Destination> destinations({DateTime? now}) {
    final DateTime base = _startOfDay(now ?? DateTime.now());

    return <Destination>[
      Destination(
        id: 'paris',
        city: 'Paris',
        country: 'France',
        imageAsset: 'assets/images/paris_explore.jpg',
        distanceKm: 5837,
        rating: 4.8,
        summary:
            'Boulevards, riverside walks and the best museum mile in Europe. '
            'An overnight flight puts you there for breakfast.',
        categories: <PlaceCategory>[PlaceCategory.city],
        trip: _returnTrip(
          base: base,
          departsInDays: 14,
          toCity: 'Paris',
          toCode: 'CDG',
          outboundHour: 19,
          flightMinutes: 440,
          stayNights: 4,
          returnHour: 13,
          price: 612,
          seatsLeft: 12,
          flightNumber: 'GT 218',
          returnFlightNumber: 'GT 219',
        ),
      ),
      Destination(
        id: 'london',
        city: 'London',
        country: 'United Kingdom',
        imageAsset: 'assets/images/london_explore.jpg',
        distanceKm: 5570,
        rating: 4.7,
        summary:
            'Free museums, a thousand years of history and the best theatre '
            'anywhere. The shortest hop across the Atlantic.',
        categories: <PlaceCategory>[PlaceCategory.city],
        trip: _returnTrip(
          base: base,
          departsInDays: 10,
          toCity: 'London',
          toCode: 'LHR',
          outboundHour: 21,
          flightMinutes: 420,
          stayNights: 4,
          returnHour: 11,
          price: 548,
          seatsLeft: 9,
          flightNumber: 'GT 100',
          returnFlightNumber: 'GT 101',
        ),
      ),
      Destination(
        id: 'bangkok',
        city: 'Bangkok',
        country: 'Thailand',
        imageAsset: 'assets/images/bangkok_explore.jpg',
        distanceKm: 13930,
        rating: 4.7,
        summary:
            'The most-visited city on earth: temples, canals, night markets, '
            'and beaches a short hop further south.',
        categories: <PlaceCategory>[PlaceCategory.city, PlaceCategory.beach],
        trip: _returnTrip(
          base: base,
          departsInDays: 38,
          toCity: 'Bangkok',
          toCode: 'BKK',
          outboundHour: 8,
          flightMinutes: 1110,
          stayNights: 10,
          returnHour: 23,
          price: 1042,
          seatsLeft: 6,
          flightNumber: 'GT 770',
          returnFlightNumber: 'GT 771',
        ),
      ),
      Destination(
        id: 'dubai',
        city: 'Dubai',
        country: 'United Arab Emirates',
        imageAsset: 'assets/images/dubai_explore.jpg',
        distanceKm: 11000,
        rating: 4.6,
        summary:
            'Skyline, souks and warm water in December. Good as a trip in '
            'itself or as a stopover further east.',
        categories: <PlaceCategory>[PlaceCategory.city, PlaceCategory.beach],
        trip: _returnTrip(
          base: base,
          departsInDays: 24,
          toCity: 'Dubai',
          toCode: 'DXB',
          outboundHour: 22,
          flightMinutes: 740,
          stayNights: 6,
          returnHour: 9,
          price: 878,
          seatsLeft: 15,
          flightNumber: 'GT 640',
          returnFlightNumber: 'GT 641',
        ),
      ),
      Destination(
        id: 'istanbul',
        city: 'Istanbul',
        country: 'Türkiye',
        imageAsset: 'assets/images/istanbul_explore.jpg',
        distanceKm: 8060,
        rating: 4.7,
        summary:
            'Two continents, one city. Hagia Sophia, the Bosphorus ferries '
            'and the best breakfast on this list.',
        categories: <PlaceCategory>[PlaceCategory.city],
        trip: _returnTrip(
          base: base,
          departsInDays: 20,
          toCity: 'Istanbul',
          toCode: 'IST',
          outboundHour: 18,
          flightMinutes: 605,
          stayNights: 5,
          returnHour: 15,
          price: 704,
          seatsLeft: 4,
          flightNumber: 'GT 330',
          returnFlightNumber: 'GT 331',
        ),
      ),
      Destination(
        id: 'rome',
        city: 'Rome',
        country: 'Italy',
        imageAsset: 'assets/images/rome_explore.jpg',
        distanceKm: 6888,
        rating: 4.8,
        summary:
            'An open-air museum you can walk end to end. Go in spring, before '
            'the queues and the heat arrive together.',
        categories: <PlaceCategory>[PlaceCategory.city],
        trip: _returnTrip(
          base: base,
          departsInDays: 30,
          toCity: 'Rome',
          toCode: 'FCO',
          outboundHour: 17,
          flightMinutes: 540,
          stayNights: 6,
          returnHour: 12,
          price: 668,
          seatsLeft: 11,
          flightNumber: 'GT 410',
          returnFlightNumber: 'GT 411',
        ),
      ),
      Destination(
        id: 'barcelona',
        city: 'Barcelona',
        country: 'Spain',
        imageAsset: 'assets/images/barcelona_explore.jpg',
        distanceKm: 6150,
        rating: 4.7,
        summary:
            'Gaudí, tapas and a city beach you can reach on the metro. Easy '
            'to combine with the rest of Catalonia.',
        categories: <PlaceCategory>[PlaceCategory.city, PlaceCategory.beach],
        trip: _returnTrip(
          base: base,
          departsInDays: 27,
          toCity: 'Barcelona',
          toCode: 'BCN',
          outboundHour: 18,
          flightMinutes: 490,
          stayNights: 5,
          returnHour: 14,
          price: 634,
          seatsLeft: 8,
          flightNumber: 'GT 520',
          returnFlightNumber: 'GT 521',
        ),
      ),
      Destination(
        id: 'tokyo',
        city: 'Tokyo',
        country: 'Japan',
        imageAsset: 'assets/images/tokyo_explore.jpg',
        distanceKm: 10850,
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
          outboundHour: 13,
          flightMinutes: 840,
          stayNights: 8,
          returnHour: 17,
          price: 1128,
          seatsLeft: 7,
          flightNumber: 'GT 550',
          returnFlightNumber: 'GT 551',
        ),
      ),
      Destination(
        id: 'toronto',
        city: 'Toronto',
        country: 'Canada',
        imageAsset: 'assets/images/toronto_canada.jpg',
        distanceKm: 550,
        rating: 4.6,
        summary:
            'Lakefront city with Algonquin canoe country and dense pine '
            'forest a few hours north. The short-haul option.',
        categories: <PlaceCategory>[
          PlaceCategory.city,
          PlaceCategory.lakes,
          PlaceCategory.forest,
          PlaceCategory.camp,
        ],
        trip: _returnTrip(
          base: base,
          departsInDays: 12,
          toCity: 'Toronto',
          toCode: 'YYZ',
          outboundHour: 7,
          flightMinutes: 95,
          stayNights: 3,
          returnHour: 19,
          price: 214,
          seatsLeft: 18,
          flightNumber: 'GT 802',
          returnFlightNumber: 'GT 803',
        ),
      ),
      Destination(
        id: 'moscow',
        city: 'Moscow',
        country: 'Russia',
        imageAsset: 'assets/images/russia_explore.jpg',
        distanceKm: 7519,
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
          outboundHour: 16,
          flightMinutes: 580,
          stayNights: 6,
          returnHour: 13,
          price: 796,
          seatsLeft: 5,
          flightNumber: 'GT 440',
          returnFlightNumber: 'GT 441',
        ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Flights leaving today
  // ---------------------------------------------------------------------------

  /// Today's departures from [currentCity], for the flights board.
  static List<DailyFlight> dailyFlights({DateTime? now}) {
    final DateTime base = _startOfDay(now ?? DateTime.now());

    final List<_FlightSeed> seeds = <_FlightSeed>[
      const _FlightSeed(
        'GT 802',
        'GoTrek Air',
        'YYZ',
        'Toronto',
        6,
        15,
        95,
        214,
        18,
      ),
      const _FlightSeed(
        'GT 100',
        'GoTrek Air',
        'LHR',
        'London',
        8,
        40,
        420,
        548,
        9,
      ),
      const _FlightSeed(
        'GT 410',
        'Alpine Air',
        'FCO',
        'Rome',
        10,
        5,
        540,
        668,
        11,
      ),
      const _FlightSeed(
        'GT 218',
        'GoTrek Air',
        'CDG',
        'Paris',
        12,
        30,
        440,
        612,
        12,
      ),
      const _FlightSeed(
        'GT 640',
        'Gulf Star',
        'DXB',
        'Dubai',
        14,
        50,
        740,
        878,
        15,
      ),
      const _FlightSeed(
        'GT 550',
        'Pacific Blue',
        'HND',
        'Tokyo',
        16,
        20,
        840,
        1128,
        7,
      ),
      const _FlightSeed(
        'GT 330',
        'Bosphorus',
        'IST',
        'Istanbul',
        18,
        45,
        605,
        704,
        4,
      ),
      const _FlightSeed(
        'GT 520',
        'Iberia Wing',
        'BCN',
        'Barcelona',
        21,
        10,
        490,
        634,
        8,
      ),
    ];

    return <DailyFlight>[
      for (final _FlightSeed seed in seeds)
        () {
          final DateTime departsAt = base.add(
            Duration(hours: seed.hour, minutes: seed.minute),
          );
          return DailyFlight(
            id: 'flight-${seed.flightNumber.replaceAll(' ', '-').toLowerCase()}',
            airline: seed.airline,
            flightNumber: seed.flightNumber,
            fromCode: currentCity.airportCode,
            fromCity: currentCity.city,
            toCode: seed.toCode,
            toCity: seed.toCity,
            departsAt: departsAt,
            arrivesAt: departsAt.add(Duration(minutes: seed.minutes)),
            price: seed.price,
            cabin: 'Economy',
            seatsLeft: seed.seatsLeft,
            isDirect: seed.minutes < 900,
          );
        }(),
    ];
  }

  // ---------------------------------------------------------------------------
  // Current-city content
  // ---------------------------------------------------------------------------

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
    required int seatsLeft,
    required String flightNumber,
    required String returnFlightNumber,
    String cabin = 'Economy',
  }) {
    final DateTime outboundDeparture = base.add(
      Duration(days: departsInDays, hours: outboundHour),
    );
    final DateTime inboundDeparture = base.add(
      Duration(days: departsInDays + stayNights, hours: returnHour),
    );

    return TripOffer(
      outbound: FlightLeg(
        fromCity: currentCity.city,
        fromCode: currentCity.airportCode,
        toCity: toCity,
        toCode: toCode,
        departsAt: outboundDeparture,
        arrivesAt: outboundDeparture.add(Duration(minutes: flightMinutes)),
        flightNumber: flightNumber,
      ),
      inbound: FlightLeg(
        fromCity: toCity,
        fromCode: toCode,
        toCity: currentCity.city,
        toCode: currentCity.airportCode,
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

/// Compact row for the daily flight table above.
class _FlightSeed {
  const _FlightSeed(
    this.flightNumber,
    this.airline,
    this.toCode,
    this.toCity,
    this.hour,
    this.minute,
    this.minutes,
    this.price,
    this.seatsLeft,
  );

  final String flightNumber;
  final String airline;
  final String toCode;
  final String toCity;
  final int hour;
  final int minute;
  final int minutes;
  final double price;
  final int seatsLeft;
}
