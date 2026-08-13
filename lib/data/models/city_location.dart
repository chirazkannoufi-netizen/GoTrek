/// A city the app can show local content for.
///
/// Only one city is populated today (New York); the rest are listed in the
/// location picker so the control is honest about what it can switch to.
class CityLocation {
  const CityLocation({
    required this.id,
    required this.city,
    required this.country,
    required this.airportCode,
    required this.isAvailable,
    this.imageAsset = '',
  });

  final String id;
  final String city;
  final String country;
  final String airportCode;

  /// Whether the catalogue has stays, places and activities for this city.
  final bool isAvailable;

  final String imageAsset;

  String get label => '$city, $country';
}
