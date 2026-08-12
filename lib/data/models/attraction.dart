import 'catalog_item.dart';

/// A landmark shown in the "Most visited" rail. Free to visit, so it has no
/// price and is not bookable.
class Attraction extends CatalogItem {
  const Attraction({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.area,
    required this.imageAsset,
    required this.rating,
    required this.reviewCount,
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

  @override
  SavedKind get kind => SavedKind.attraction;

  @override
  String get title => name;

  @override
  String get subtitle => area;

  @override
  double? get priceFrom => null;
}
