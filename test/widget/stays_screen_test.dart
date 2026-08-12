import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/widgets/cards/hotel_card.dart';
import 'package:gotrek_app/core/widgets/state_views.dart';
import 'package:gotrek_app/features/stays/stays_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('lists the seeded stays', (WidgetTester tester) async {
    await pumpAppWidget(tester, const StaysScreen());

    expect(find.byType(HotelCard), findsNWidgets(5));
    expect(find.text('The Plaza Hotel'), findsOneWidget);
  });

  testWidgets('defaults to cheapest first', (WidgetTester tester) async {
    await pumpAppWidget(tester, const StaysScreen());

    final Iterable<HotelCard> cards = tester.widgetList<HotelCard>(
      find.byType(HotelCard),
    );
    final List<double> prices =
        cards.map((HotelCard card) => card.hotel.pricePerNight).toList();

    expect(prices, orderedEquals(<double>[...prices]..sort()));
  });

  testWidgets('search filters the stays', (WidgetTester tester) async {
    await pumpAppWidget(tester, const StaysScreen());

    await tester.enterText(find.byType(TextField).first, 'peninsula');
    await tester.pumpAndSettle();

    expect(find.byType(HotelCard), findsOneWidget);
    expect(find.text('The Peninsula New York'), findsOneWidget);
  });

  testWidgets('an unmatched search shows the empty state', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const StaysScreen());

    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.byType(HotelCard), findsNothing);
  });
}
