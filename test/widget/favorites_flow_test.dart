import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/widgets/cards/saved_item_card.dart';
import 'package:gotrek_app/core/widgets/favorite_button.dart';
import 'package:gotrek_app/core/widgets/state_views.dart';
import 'package:gotrek_app/features/favorites/favorites_screen.dart';
import 'package:gotrek_app/features/stays/stays_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('favourites starts empty and offers a way out', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const FavoritesScreen());

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.text('Clear all'), findsNothing);
  });

  testWidgets('saving a stay from the list makes it appear in favourites', (
    WidgetTester tester,
  ) async {
    // Both screens share one ProviderScope, which is what makes the saved
    // state visible across tabs in the real app.
    await pumpAppWidget(
      tester,
      const Column(
        children: <Widget>[
          Expanded(child: StaysScreen()),
          Expanded(child: FavoritesScreen()),
        ],
      ),
    );

    expect(find.byType(EmptyView), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(SavedItemCard), findsOneWidget);
    expect(find.byType(EmptyView), findsNothing);
  });

  testWidgets('unsaving removes it again', (WidgetTester tester) async {
    await pumpAppWidget(
      tester,
      const Column(
        children: <Widget>[
          Expanded(child: StaysScreen()),
          Expanded(child: FavoritesScreen()),
        ],
      ),
    );

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(SavedItemCard), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(SavedItemCard), findsNothing);
    expect(find.byType(EmptyView), findsOneWidget);
  });
}
