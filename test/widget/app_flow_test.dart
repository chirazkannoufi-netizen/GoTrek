import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/app/gotrek_app.dart';
import 'package:gotrek_app/core/widgets/booking_bar.dart';
import 'package:gotrek_app/core/widgets/favorite_button.dart';

import '../helpers/test_harness.dart';

/// Boots the real app and walks it the way a user would, so navigation and
/// the booking flow are exercised end to end rather than screen by screen.
void main() {
  /// Welcome -> Home, with no account. This is the guest path.
  Future<void> bootToHome(WidgetTester tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const GoTrekApp()),
    );
    await tester.pump();
    expect(find.text('Every trip starts here'), findsOneWidget);

    await tester.drag(find.byType(GestureDetector).last, const Offset(400, 0));
    await tester.pumpAndSettle();
  }

  /// The nav bar and the cards share Icons.favorite_border, so tab taps are
  /// scoped to the NavigationBar.
  Finder navIcon(IconData icon) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byIcon(icon),
  );

  /// Completes the sign-in prompt that is currently on screen: the sheet
  /// first, then the login form behind it.
  Future<void> passThroughAuthGate(WidgetTester tester) async {
    await tester.tap(find.text('Log in or sign up').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'chiraz@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'trekking1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
  }

  group('guest access', () {
    testWidgets('the welcome slider goes straight to Home, not login', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      expect(find.text('Most visited'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('a guest can browse every tab', (WidgetTester tester) async {
      await bootToHome(tester);

      await tester.tap(navIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();
      expect(find.text('10 destinations'), findsOneWidget);

      await tester.tap(navIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.text('Nothing saved yet'), findsOneWidget);

      await tester.tap(navIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      expect(find.text('You are browsing as a guest'), findsOneWidget);
      expect(find.text('Log out'), findsNothing);
    });

    testWidgets('saving a place asks a guest to sign in first', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      await tester.tap(find.byType(FavoriteButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Sign in to save places'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(find.text('Most visited'), findsOneWidget);
    });

    testWidgets('signing in through the gate completes the save', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);
      await tester.tap(navIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      // The guest card's button opens the prompt sheet.
      await tester.tap(find.text('Log in or sign up'));
      await tester.pumpAndSettle();
      await passThroughAuthGate(tester);

      // Back on Profile, now signed in.
      expect(find.text('You are browsing as a guest'), findsNothing);
      expect(find.text('Saved places'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
    });
  });

  group('home is the current city', () {
    testWidgets('the location control opens the picker, not Explore', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      await tester.tap(find.text('New York, USA'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your location'), findsOneWidget);
      expect(find.text('Not available yet'), findsWidgets);
    });

    testWidgets('home search filters within the city instead of redirecting', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      await tester.enterText(find.byType(TextField).first, 'plaza');
      await tester.pumpAndSettle();

      expect(find.text('1 result in New York'), findsOneWidget);
      expect(find.text('The Plaza Hotel'), findsOneWidget);
      // Still on Home — the nav bar has not moved to Explore.
      expect(find.text('10 destinations'), findsNothing);
    });

    testWidgets('an unmatched home search shows an empty state', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      await tester.enterText(find.byType(TextField).first, 'reykjavik');
      await tester.pumpAndSettle();

      expect(
        find.text('Nothing in New York matches "reykjavik"'),
        findsOneWidget,
      );
    });

    testWidgets('there is no category chip row on Home', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      expect(find.widgetWithText(FilterChip, 'Mountains'), findsNothing);
      expect(find.widgetWithText(FilterChip, 'Beach'), findsNothing);
    });

    testWidgets('the Flights service opens the departures board', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);

      await tester.tap(find.text('Flights'));
      await tester.pumpAndSettle();

      expect(find.text('Flights today'), findsOneWidget);
      expect(find.textContaining('Departing New York (JFK)'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);
    });
  });

  group('explore is trips elsewhere', () {
    testWidgets('lists world destinations and excludes the current city', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);
      await tester.tap(navIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Trips from New York'), findsOneWidget);
      expect(find.text('10 destinations'), findsOneWidget);
      expect(find.text('New York, USA'), findsNothing);
    });

    testWidgets('booking a trip asks a guest to sign in, then checks out', (
      WidgetTester tester,
    ) async {
      await bootToHome(tester);
      await tester.tap(navIcon(Icons.explore_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View trip'));
      await tester.pumpAndSettle();
      expect(find.text('Your flights'), findsOneWidget);

      BookingBar bar() => tester.widget<BookingBar>(find.byType(BookingBar));
      expect(bar().total, 612);

      await tester.tap(find.text('Book trip'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to book this'), findsOneWidget);

      // Signing in resumes the action that was gated, so checkout opens
      // without the user having to tap "Book trip" again.
      await passThroughAuthGate(tester);

      expect(find.text('Checkout'), findsOneWidget);
      // 612 + 8% service fee, rounded.
      expect(find.text(r'$661.00'), findsWidgets);

      await tester.tap(find.text('Visa •••• 1234'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Confirm and pay'));
      await tester.pumpAndSettle();

      expect(find.text('Booking confirmed'), findsOneWidget);
      expect(find.textContaining('Reference GT-'), findsOneWidget);
    });
  });
}
