/// The kinds of content a user can save.
enum SavedKind { destination, hotel, experience, attraction }

/// A stable pointer to a saved item, cheap enough to persist as a string.
class FavoriteRef {
  const FavoriteRef(this.kind, this.id);

  final SavedKind kind;
  final String id;

  String encode() => '${kind.name}:$id';

  static FavoriteRef? decode(String raw) {
    final int separator = raw.indexOf(':');
    if (separator <= 0 || separator == raw.length - 1) return null;
    final String kindName = raw.substring(0, separator);
    for (final SavedKind kind in SavedKind.values) {
      if (kind.name == kindName) {
        return FavoriteRef(kind, raw.substring(separator + 1));
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is FavoriteRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => encode();
}

/// Shared surface for everything that appears as a card and can be saved.
///
/// Letting the four content types share this lets the favourites screen and
/// the save button work without knowing which type they are holding.
abstract class CatalogItem {
  const CatalogItem();

  String get id;
  SavedKind get kind;
  String get title;
  String get subtitle;
  String get imageAsset;
  double get rating;

  /// Lowest price this item can be booked from, or `null` if it is free to
  /// visit (attractions).
  double? get priceFrom;

  FavoriteRef get favoriteRef => FavoriteRef(kind, id);
}
