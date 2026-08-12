import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/app/gotrek_app.dart';
import 'package:gotrek_app/core/widgets/booking_bar.dart';

import '../helpers/test_harness.dart';

/// Boots the real app and walks it the way a user would, so navigation and
/// the booking flow are exercised end to end rather than screen by screen.
void main() {
  Future<void> bootToLogin(WidgetTester tester) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(overrides: testOverrides(), child: const GoTrekApp()),
    );
    // The welcome screen runs a looping pulse animation, so settle only after
    // it has been left behind.
    await tester.pump();
    expect(find.text('Every trip starts here'), findsOneWidget);

    await tester.drag(
      find.byIcon(Icons.arrow_forward_rounded),
      const Offset(400, 0),
    );
    await tester.pumpAndSettle();
  }

  Future<void> bootToHome(WidgetTester tester) async {
    await bootToLogin(tester);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'chiraz@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'trekking1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome slider leads to the login form', (
    WidgetTester tester,
  ) async {
    await bootToLogin(tester);

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('login rejects a malformed email before submitting', (
    WidgetTester tester,
  ) async {
    await bootToLogin(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'not-an-email');
    await tester.enterText(find.byType(TextFormField).at(1), 'trekking1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('a valid login lands on the home shell', (
    WidgetTester tester,
  ) async {
    await bootToHome(tester);

    expect(find.text('Most visited'), findsOneWidget);
    expect(find.text('Places to stay'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('the tab bar switches tabs without stacking routes', (
    WidgetTester tester,
  ) async {
    await bootToHome(tester);

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    expect(find.text('5 destinations'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();
    expect(find.text('Saved places'), findsOneWidget);

    // Back returns to Home rather than popping the app, because the shell
    // keeps a single route.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Most visited'), findsOneWidget);
  });

  testWidgets('booking a trip carries the real total through to confirmation', (
    WidgetTester tester,
  ) async {
    await bootToHome(tester);

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View trip'));
    await tester.pumpAndSettle();

    // Paris is first in the list and costs $189 per traveller.
    expect(find.text('Your flights'), findsOneWidget);
    expect(find.textContaining(r'$189'), findsWidgets);

    await tester.tap(find.text('Book trip'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    // 189 + 8% service fee, rounded.
    expect(find.text(r'$204.00'), findsWidgets);

    // Paying is blocked until a card is chosen.
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Select a payment method'),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('Visa •••• 1234'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm and pay'));
    await tester.pumpAndSettle();

    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.textContaining('Reference GT-'), findsOneWidget);
    expect(find.text(r'$204.00'), findsOneWidget);
  });

  testWidgets('the confirmed booking shows up under My bookings', (
    WidgetTester tester,
  ) async {
    await bootToHome(tester);

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Book trip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Visa •••• 1234'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm and pay'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'View my bookings'));
    await tester.pumpAndSettle();

    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('Paris, France'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
  });

  testWidgets('the traveller stepper changes the total on the booking bar', (
    WidgetTester tester,
  ) async {
    await bootToHome(tester);

    await tester.tap(find.byIcon(Icons.explore_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View trip'));
    await tester.pumpAndSettle();

    BookingBar bar() => tester.widget<BookingBar>(find.byType(BookingBar));
    expect(bar().total, 189);

    await tester.scrollUntilVisible(find.byTooltip('Add a traveller'), 300);
    await tester.tap(find.byTooltip('Add a traveller'));
    await tester.pumpAndSettle();

    expect(bar().total, 378);
  });
}
