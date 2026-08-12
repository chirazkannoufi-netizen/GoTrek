import 'package:intl/intl.dart';

/// Display formatting used across the app, so numbers and dates look the
/// same on every screen.
abstract final class Formatters {
  static final NumberFormat _whole = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 0,
  );
  static final NumberFormat _precise = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );
  static final NumberFormat _thousands = NumberFormat.decimalPattern('en_US');
  static final DateFormat _dayMonth = DateFormat('EEE, d MMM');
  static final DateFormat _fullDate = DateFormat('d MMMM y');
  static final DateFormat _shortDate = DateFormat('d MMM y');
  static final DateFormat _time = DateFormat('HH:mm');

  static String money(double amount) => _whole.format(amount);

  static String moneyPrecise(double amount) => _precise.format(amount);

  static String dayMonth(DateTime date) => _dayMonth.format(date);

  static String fullDate(DateTime date) => _fullDate.format(date);

  static String shortDate(DateTime date) => _shortDate.format(date);

  static String time(DateTime date) => _time.format(date);

  static String flightDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }

  static String nights(int count) => count == 1 ? '1 night' : '$count nights';

  static String guests(int count) => count == 1 ? '1 guest' : '$count guests';

  static String distance(double km) => km >= 100
      ? '${_thousands.format(km.round())} km away'
      : '${km.toStringAsFixed(1)} km away';

  /// 1200 -> "1.2k", used for review counts.
  static String compactCount(int value) {
    if (value < 1000) return '$value';
    final double thousands = value / 1000;
    return '${thousands.toStringAsFixed(thousands < 10 ? 1 : 0)}k';
  }

  static String rating(double value) => value.toStringAsFixed(1);
}
