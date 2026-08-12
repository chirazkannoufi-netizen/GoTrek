/// One direction of a return trip.
class FlightLeg {
  const FlightLeg({
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
    required this.departsAt,
    required this.arrivesAt,
    required this.flightNumber,
  });

  final String fromCity;
  final String fromCode;
  final String toCity;
  final String toCode;
  final DateTime departsAt;
  final DateTime arrivesAt;
  final String flightNumber;

  Duration get duration => arrivesAt.difference(departsAt);
}

/// A return flight offer attached to a destination.
class TripOffer {
  const TripOffer({
    required this.outbound,
    required this.inbound,
    required this.pricePerTraveller,
    required this.cabin,
    required this.seatsLeft,
  });

  final FlightLeg outbound;
  final FlightLeg inbound;
  final double pricePerTraveller;
  final String cabin;
  final int seatsLeft;

  int get nights => inbound.departsAt.difference(outbound.arrivesAt).inDays;

  double totalFor(int travellers) => pricePerTraveller * travellers;
}
