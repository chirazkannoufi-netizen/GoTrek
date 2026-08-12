import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/widgets/cards/destination_card.dart';
import 'package:gotrek_app/core/widgets/state_views.dart';
import 'package:gotrek_app/features/explore/explore_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('lists every seeded destination', (WidgetTester tester) async {
    await pumpAppWidget(tester, const ExploreScreen());

    expect(find.text('5 destinations'), findsOneWidget);
    expect(find.byType(DestinationHeroCard), findsOneWidget);
    // The remaining four are in a lazy grid, so only the on-screen ones are
    // built at this viewport size.
    expect(find.byType(DestinationListCard), findsAtLeastNWidgets(2));
  });

  testWidgets('search narrows the list', (WidgetTester tester) async {
    await pumpAppWidget(tester, const ExploreScreen());

    await tester.enterText(find.byType(TextField).first, 'tokyo');
    await tester.pumpAndSettle();

    expect(find.text('1 destination'), findsOneWidget);
    expect(find.byType(DestinationListCard), findsNothing);
    expect(find.text('Tokyo, Japan'), findsOneWidget);
  });

  testWidgets('a search with no results shows the empty state', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const ExploreScreen());

    await tester.enterText(find.byType(TextField).first, 'atlantis');
    await tester.pumpAndSettle();

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('No destinations match that'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
  });

  testWidgets('clearing the filters restores the full list', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const ExploreScreen());

    await tester.enterText(find.byType(TextField).first, 'atlantis');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();

    expect(find.text('5 destinations'), findsOneWidget);
  });

  testWidgets('a category chip filters to the destinations tagged with it', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const ExploreScreen());

    await tester.tap(find.widgetWithText(FilterChip, 'Beach'));
    await tester.pumpAndSettle();

    expect(find.text('1 destination in Beach'), findsOneWidget);
    expect(find.text('New York, USA'), findsOneWidget);
  });
}
