import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';

/// Bookings made in the app, persisted on the device.
class BookingRepository {
  BookingRepository({Random? random}) : _random = random ?? Random();

  static const String _key = 'gotrek.bookings';
  static const String _referenceAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final Random _random;

  Future<List<Booking>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? const <String>[];
    final List<Booking> bookings = <Booking>[];
    for (final String entry in raw) {
      try {
        bookings.add(
          Booking.fromJson(jsonDecode(entry) as Map<String, dynamic>),
        );
      } on FormatException {
        continue;
      }
    }
    bookings.sort((Booking a, Booking b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  Future<void> save(List<Booking> bookings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      bookings.map((Booking b) => jsonEncode(b.toJson())).toList(),
    );
  }

  /// A human-readable booking reference, e.g. `GT-7KQ4M2`.
  String newReference() {
    final String body =
        List<String>.generate(
          6,
          (_) => _referenceAlphabet[_random.nextInt(_referenceAlphabet.length)],
        ).join();
    return 'GT-$body';
  }

  String newId() =>
      'booking-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(999)}';
}
