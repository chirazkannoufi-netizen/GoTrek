import 'amenity.dart';
import 'catalog_item.dart';

/// A bookable stay.
class Hotel extends CatalogItem {
  const Hotel({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.area,
    required this.city,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.description,
    required this.amenities,
  });

  @override
  final String id;

  final String destinationId;
  final String name;
  final String area;
  final String city;

  @override
  final String imageAsset;

  @override
  final double rating;

  final int reviewCount;
  final double pricePerNight;
  final String description;
  final List<Amenity> amenities;

  @override
  SavedKind get kind => SavedKind.hotel;

  @override
  String get title => name;

  @override
  String get subtitle => '$area, $city';

  @override
  double? get priceFrom => pricePerNight;

  double totalFor({required int nights, required int rooms}) =>
      pricePerNight * nights * rooms;

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle) ||
        area.toLowerCase().contains(needle) ||
        city.toLowerCase().contains(needle);
  }
}
