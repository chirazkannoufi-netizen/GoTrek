import 'package:flutter/material.dart';

/// The category chips on the home screen. Each destination is tagged with one
/// or more of these, and selecting a chip filters the explore list.
enum PlaceCategory {
  city('City', Icons.location_city_outlined),
  mountains('Mountains', Icons.landscape_outlined),
  beach('Beach', Icons.beach_access_outlined),
  lakes('Lakes', Icons.water_outlined),
  camp('Camp', Icons.cabin_outlined),
  forest('Forest', Icons.forest_outlined);

  const PlaceCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Bookable service types. Each one is backed by real seeded data.
enum ServiceKind {
  stays('Stays', Icons.hotel_outlined),
  flights('Flights', Icons.flight_takeoff_outlined),
  experiences('Experiences', Icons.hiking_outlined);

  const ServiceKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Sort orders offered on the stays list.
enum HotelSort {
  priceLowToHigh('Price (low to high)'),
  priceHighToLow('Price (high to low)'),
  topRated('Top rated');

  const HotelSort(this.label);

  final String label;
}
