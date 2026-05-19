import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(pinned: true, title: Text('Settings')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {app.themeMode},
                  onSelectionChanged: (s) => app.setThemeMode(s.first),
                ),
                const SizedBox(height: 24),
                Text('Decimal places', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  value: app.decimalPlaces.toDouble(),
                  min: 0,
                  max: 8,
                  divisions: 8,
                  label: '${app.decimalPlaces}',
                  onChanged: (v) => app.setDecimalPlaces(v.round()),
                ),
                const SizedBox(height: 16),
                Text('Currency rates', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: app.ratesRefreshing ? null : app.refreshCurrencyRates,
                  icon: app.ratesRefreshing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh exchange rates'),
                ),
                if (app.currencyRates.lastFetchedAt != null) ...[
                  const SizedBox(height: 8),
                  Text('Last updated: ${app.currencyRates.lastFetchedAt!.toLocal()}'),
                ],
                if (app.ratesError != null) ...[
                  const SizedBox(height: 8),
                  Text(app.ratesError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
