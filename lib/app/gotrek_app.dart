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
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.namedRoutes,
    );
  }
}
