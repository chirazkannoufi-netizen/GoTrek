import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/utils/formatters.dart';

void main() {
  test('money drops the decimals', () {
    expect(Formatters.money(250), r'$250');
  });

  test('moneyPrecise keeps them, for totals', () {
    expect(Formatters.moneyPrecise(250.5), r'$250.50');
  });

  test('flightDuration omits a zero minute part', () {
    expect(Formatters.flightDuration(const Duration(hours: 9)), '9h');
    expect(
      Formatters.flightDuration(const Duration(hours: 2, minutes: 35)),
      '2h 35m',
    );
  });

  test('distance switches to whole grouped kilometres above 100', () {
    expect(Formatters.distance(12.4), '12.4 km away');
    expect(Formatters.distance(6598), '6,598 km away');
  });

  test('compactCount abbreviates thousands', () {
    expect(Formatters.compactCount(950), '950');
    expect(Formatters.compactCount(1200), '1.2k');
    expect(Formatters.compactCount(9400), '9.4k');
  });

  test('nights and guests pluralise', () {
    expect(Formatters.nights(1), '1 night');
    expect(Formatters.nights(3), '3 nights');
    expect(Formatters.guests(1), '1 guest');
    expect(Formatters.guests(2), '2 guests');
  });
}
