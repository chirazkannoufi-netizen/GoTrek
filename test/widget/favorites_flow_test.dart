import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/widgets/cards/catalog_item_card.dart';
import 'package:gotrek_app/core/widgets/favorite_button.dart';
import 'package:gotrek_app/core/widgets/state_views.dart';
import 'package:gotrek_app/data/models/user_account.dart';
import 'package:gotrek_app/features/favorites/favorites_screen.dart';
import 'package:gotrek_app/features/stays/stays_screen.dart';
import 'package:gotrek_app/state/auth_controller.dart';

import '../helpers/test_harness.dart';

/// Saving is an account action, so these pump with a signed-in session
/// already in place. The guest-prompt path is covered in app_flow_test.
class _SignedInAuth extends AuthController {
  @override
  Future<UserAccount?> build() async => const UserAccount(
    id: 'user-test',
    fullName: 'Chiraz Kannoufi',
    email: 'chiraz@example.com',
  );
}

void main() {
  List<Override> signedIn() => <Override>[
    authControllerProvider.overrideWith(_SignedInAuth.new),
  ];

  testWidgets('favourites starts empty and offers a way out', (
    WidgetTester tester,
  ) async {
    await pumpAppWidget(tester, const FavoritesScreen(), overrides: signedIn());

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
      overrides: signedIn(),
    );

    expect(find.byType(EmptyView), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();

    // Signed in, so no gate should appear.
    expect(find.text('Sign in to save places'), findsNothing);
    expect(find.byType(CatalogItemCard), findsOneWidget);
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
      overrides: signedIn(),
    );

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(CatalogItemCard), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(CatalogItemCard), findsNothing);
    expect(find.byType(EmptyView), findsOneWidget);
  });
}
