/// A single departure on the current day, for the flights board.
class DailyFlight {
  const DailyFlight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.fromCode,
    required this.fromCity,
    required this.toCode,
    required this.toCity,
    required this.departsAt,
    required this.arrivesAt,
    required this.price,
    required this.cabin,
    required this.seatsLeft,
    required this.isDirect,
  });

  final String id;
  final String airline;
  final String flightNumber;
  final String fromCode;
  final String fromCity;
  final String toCode;
  final String toCity;
  final DateTime departsAt;
  final DateTime arrivesAt;
  final double price;
  final String cabin;
  final int seatsLeft;
  final bool isDirect;

  Duration get duration => arrivesAt.difference(departsAt);

  bool get isAlmostFull => seatsLeft <= 5;

  bool hasDeparted(DateTime now) => departsAt.isBefore(now);

  double totalFor(int travellers) => price * travellers;

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return toCity.toLowerCase().contains(needle) ||
        toCode.toLowerCase().contains(needle) ||
        airline.toLowerCase().contains(needle) ||
        flightNumber.toLowerCase().contains(needle);
  }
}
