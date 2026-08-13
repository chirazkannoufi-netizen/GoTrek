import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/theme/app_theme.dart';
import 'package:gotrek_app/data/repositories/catalog_repository.dart';
import 'package:gotrek_app/state/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixed clock so seeded trip dates are stable between runs.
final DateTime testNow = DateTime(2026, 1, 15);

/// Sizes the test window like a phone, so layouts are exercised at the
/// viewport they are designed for rather than the 800x600 default.
void usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

/// The overrides every test shares: a catalogue with no artificial latency
/// and a clean preferences store.
List<Override> testOverrides() {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return <Override>[
    catalogRepositoryProvider.overrideWithValue(
      CatalogRepository(latency: Duration.zero, now: testNow),
    ),
  ];
}

/// Pumps [child] with the real theme and a catalogue that resolves without
/// the artificial delay, so tests do not have to wait on it.
/// Set [settle] to false for screens that animate continuously — the welcome
/// screen's idle loop never settles.
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const <Override>[],
  bool settle = true,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        catalogRepositoryProvider.overrideWithValue(
          CatalogRepository(latency: Duration.zero, now: testNow),
        ),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}
