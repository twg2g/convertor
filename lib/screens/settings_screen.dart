import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _buildRatesStatusCard(BuildContext context, AppState app) {
    final theme = Theme.of(context);
    final isOnline = app.isOnline;
    final isUsingFallback = app.isUsingFallbackRates;
    final isStale = app.ratesAreStale;

    IconData statusIcon;
    Color statusColor;
    String statusText;
    String detailText;

    if (!isOnline && isUsingFallback) {
      statusIcon = Icons.cloud_off;
      statusColor = theme.colorScheme.error;
      statusText = 'Offline';
      detailText = 'Using approximate fallback rates. Connect to the internet for accurate rates.';
    } else if (!isOnline) {
      statusIcon = Icons.cloud_off;
      statusColor = theme.colorScheme.secondary;
      statusText = 'Offline';
      detailText = 'Using cached rates. ${app.ratesCacheAgeDescription}.';
    } else if (isStale) {
      statusIcon = Icons.update;
      statusColor = theme.colorScheme.tertiary;
      statusText = 'Online';
      detailText = '${app.ratesCacheAgeDescription}. Tap refresh for latest rates.';
    } else {
      statusIcon = Icons.cloud_done;
      statusColor = theme.colorScheme.primary;
      statusText = 'Online';
      detailText = app.ratesCacheAgeDescription;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusText, style: theme.textTheme.titleSmall?.copyWith(color: statusColor)),
                  const SizedBox(height: 4),
                  Text(detailText, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                _buildRatesStatusCard(context, app),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: app.ratesRefreshing ? null : app.refreshCurrencyRates,
                  icon: app.ratesRefreshing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh exchange rates'),
                ),
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
