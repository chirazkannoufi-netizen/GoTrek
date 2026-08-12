import 'catalog_item.dart';
import 'place_category.dart';
import 'trip_offer.dart';

/// A city a user can explore and fly to.
class Destination extends CatalogItem {
  const Destination({
    required this.id,
    required this.city,
    required this.country,
    required this.imageAsset,
    required this.distanceKm,
    required this.rating,
    required this.summary,
    required this.categories,
    required this.trip,
  });

  @override
  final String id;

  final String city;
  final String country;

  @override
  final String imageAsset;

  final double distanceKm;

  @override
  final double rating;

  final String summary;
  final List<PlaceCategory> categories;
  final TripOffer trip;

  @override
  SavedKind get kind => SavedKind.destination;

  @override
  String get title => '$city, $country';

  @override
  String get subtitle => country;

  @override
  double? get priceFrom => trip.pricePerTraveller;

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return city.toLowerCase().contains(needle) ||
        country.toLowerCase().contains(needle) ||
        summary.toLowerCase().contains(needle);
  }
}
