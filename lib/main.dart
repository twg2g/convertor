import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'router/app_router.dart';
import 'services/currency_rates_repository.dart';
import 'services/preferences_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = PreferencesService();
  final rates = CurrencyRatesRepository();
  await rates.loadFromDisk();
  final appState = AppState(
    preferences: preferences,
    currencyRates: rates,
  );
  await appState.bootstrap();
  final router = createAppRouter();
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: UniversalConverterApp(router: router),
    ),
  );
}
