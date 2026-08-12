import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrek_app/core/theme/app_theme.dart';
import 'package:gotrek_app/data/repositories/catalog_repository.dart';
import 'package:gotrek_app/state/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fixed clock so seeded trip dates are stable between runs.
final DateTime testNow = DateTime(2026, 1, 15);

/// Pumps [child] with the real theme and a catalogue that resolves without
/// the artificial delay, so tests do not have to wait on it.
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const <Override>[],
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
  await tester.pumpAndSettle();
}
