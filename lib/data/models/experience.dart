import 'catalog_item.dart';

/// A guided tour or activity — the "Top events" rail on the home screen.
class Experience extends CatalogItem {
  const Experience({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.area,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.duration,
    required this.startsAt,
    required this.description,
  });

  @override
  final String id;

  final String destinationId;
  final String name;
  final String area;

  @override
  final String imageAsset;

  @override
  final double rating;

  final int reviewCount;
  final double price;
  final Duration duration;
  final DateTime startsAt;
  final String description;

  @override
  SavedKind get kind => SavedKind.experience;

  @override
  String get title => name;

  @override
  String get subtitle => area;

  @override
  double? get priceFrom => price;

  double totalFor(int guests) => price * guests;

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle) ||
        area.toLowerCase().contains(needle);
  }
}
