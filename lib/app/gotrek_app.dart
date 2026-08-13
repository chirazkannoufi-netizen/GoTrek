import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_routes.dart';

class GoTrekApp extends StatelessWidget {
  const GoTrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoTrek',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Light is the product default; the dark theme stays available but is
      // not driven by the device setting.
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.namedRoutes,
    );
  }
}
