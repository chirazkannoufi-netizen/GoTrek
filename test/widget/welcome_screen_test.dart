import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/theme/app_fonts.dart';
import 'package:gotrek_app/features/onboarding/welcome_screen.dart';
import 'package:gotrek_app/features/onboarding/widgets/takeoff_slider.dart';

import '../helpers/test_harness.dart';

void main() {
  /// The welcome screen animates continuously while idle, so these pump a
  /// single frame rather than settling.
  Future<void> pumpWelcome(WidgetTester tester) async {
    usePhoneViewport(tester);
    await pumpAppWidget(tester, const WelcomeScreen(), settle: false);
  }

  testWidgets('shows the tagline and nothing else in prose', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);

    expect(find.text("Let's make our life so life"), findsOneWidget);
    // Copy from earlier revisions must not linger.
    expect(find.text('Every trip starts here'), findsNothing);
    expect(find.textContaining('No account needed'), findsNothing);
  });

  testWidgets('the tagline is set in the bundled italic display face', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);

    final Text tagline = tester.widget<Text>(
      find.text("Let's make our life so life"),
    );

    expect(tagline.style?.fontFamily, AppFonts.display);
    expect(tagline.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('the slide control carries an aeroplane', (
    WidgetTester tester,
  ) async {
    await pumpWelcome(tester);

    expect(find.byType(TakeoffSlider), findsOneWidget);
    expect(find.byIcon(Icons.flight), findsOneWidget);
    expect(find.text('Slide to start'), findsOneWidget);
  });

  testWidgets('a short drag springs back without completing', (
    WidgetTester tester,
  ) async {
    bool completed = false;
    usePhoneViewport(tester);
    await pumpAppWidget(
      tester,
      Scaffold(
        body: Center(child: TakeoffSlider(onCompleted: () => completed = true)),
      ),
      settle: false,
    );

    await tester.drag(find.byIcon(Icons.flight), const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 400));

    expect(completed, isFalse);
  });

  testWidgets('dragging past the threshold reports completion', (
    WidgetTester tester,
  ) async {
    bool completed = false;
    usePhoneViewport(tester);
    await pumpAppWidget(
      tester,
      Scaffold(
        body: Center(child: TakeoffSlider(onCompleted: () => completed = true)),
      ),
      settle: false,
    );

    await tester.drag(find.byIcon(Icons.flight), const Offset(400, 0));
    // The idle loop stops once the gesture completes, so this settles on the
    // take-off flourish and returns when the callback has fired.
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });
}
