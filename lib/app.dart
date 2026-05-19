import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'theme/app_theme.dart';

class UniversalConverterApp extends StatelessWidget {
  const UniversalConverterApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return MaterialApp.router(
      title: 'Universal Converter',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: app.themeMode,
      routerConfig: router,
    );
  }
}
