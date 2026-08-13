import '../../core/theme/app_spacing.dart';
import '../models/attraction.dart';
import '../models/catalog_item.dart';
import '../models/city_location.dart';
import '../models/daily_flight.dart';
import '../models/destination.dart';
import '../models/experience.dart';
import '../models/hotel.dart';
import '../models/payment_card.dart';
import '../seed/seed_catalog.dart';

/// Read access to the travel catalogue.
///
/// Backed by [SeedCatalog] today. The screens only ever see this interface, so
/// swapping in an HTTP client later is a change to this one class.
class CatalogRepository {
  CatalogRepository({Duration? latency, DateTime? now})
    : _latency = latency ?? AppDurations.fakeNetwork,
      _now = now;

  final Duration _latency;
  final DateTime? _now;

  List<Destination>? _destinations;
  List<DailyFlight>? _dailyFlights;
  List<Hotel>? _hotels;
  List<Attraction>? _attractions;
  List<Experience>? _experiences;

  /// Applied once per collection, so the UI exercises its loading state
  /// without every later read paying for it.
  Future<void> _settle(bool alreadyLoaded) async {
    if (alreadyLoaded || _latency == Duration.zero) return;
    await Future<void>.delayed(_latency);
  }

  Future<List<Destination>> destinations() async {
    await _settle(_destinations != null);
    return _destinations ??= SeedCatalog.destinations(now: _now);
  }

  Future<Destination> destinationById(String id) async {
    final List<Destination> all = await destinations();
    for (final Destination destination in all) {
      if (destination.id == id) return destination;
    }
    throw CatalogNotFoundException('No destination with id "$id"');
  }

  Future<List<Hotel>> hotels({String? destinationId}) async {
    await _settle(_hotels != null);
    final List<Hotel> all = _hotels ??= SeedCatalog.hotels();
    if (destinationId == null) return all;
    return all
        .where((Hotel hotel) => hotel.destinationId == destinationId)
        .toList();
  }

  Future<Hotel> hotelById(String id) async {
    final List<Hotel> all = await hotels();
    for (final Hotel hotel in all) {
      if (hotel.id == id) return hotel;
    }
    throw CatalogNotFoundException('No hotel with id "$id"');
  }

  Future<List<Attraction>> attractions({String? cityId}) async {
    await _settle(_attractions != null);
    final List<Attraction> all = _attractions ??= SeedCatalog.attractions();
    if (cityId == null) return all;
    return all
        .where((Attraction attraction) => attraction.destinationId == cityId)
        .toList();
  }

  Future<List<Experience>> experiences({String? cityId}) async {
    await _settle(_experiences != null);
    final List<Experience> all =
        _experiences ??= SeedCatalog.experiences(now: _now);
    if (cityId == null) return all;
    return all
        .where((Experience experience) => experience.destinationId == cityId)
        .toList();
  }

  /// Departures leaving [SeedCatalog.currentCity] today.
  Future<List<DailyFlight>> dailyFlights() async {
    await _settle(_dailyFlights != null);
    return _dailyFlights ??= SeedCatalog.dailyFlights(now: _now);
  }

  Future<List<CityLocation>> selectableCities() async =>
      SeedCatalog.selectableCities();

  Future<List<PaymentCard>> paymentCards() async => SeedCatalog.paymentCards();

  /// Turns a saved reference back into the item it points at, or `null` if the
  /// item is no longer in the catalogue.
  Future<CatalogItem?> resolve(FavoriteRef ref) async {
    final List<CatalogItem> pool = switch (ref.kind) {
      SavedKind.destination => await destinations(),
      SavedKind.hotel => await hotels(),
      SavedKind.attraction => await attractions(),
      SavedKind.experience => await experiences(),
    };
    for (final CatalogItem item in pool) {
      if (item.id == ref.id) return item;
    }
    return null;
  }
}

class CatalogNotFoundException implements Exception {
  const CatalogNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}
