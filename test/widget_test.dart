// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:universal_converter/screens/home_screen.dart';
import 'package:universal_converter/services/currency_rates_repository.dart';
import 'package:universal_converter/services/preferences_service.dart';
import 'package:universal_converter/state/app_state.dart';

void main() {
  testWidgets('Home shows main categories', (WidgetTester tester) async {
    final appState = AppState(
      preferences: PreferencesService(),
      currencyRates: CurrencyRatesRepository(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.text('Universal Converter'), findsWidgets);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Length'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Temperature'), findsOneWidget);
  });
}
