import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../converters/category_engine.dart';
import '../data/category_data.dart';
import '../models/conversion_category.dart';
import '../models/recent_conversion.dart';
import '../models/unit_definition.dart';
import '../state/app_state.dart';
import '../utils/format_utils.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.categoryId,
    this.initialFromId,
    this.initialToId,
    this.initialValueQuery,
  });

  final String categoryId;
  final String? initialFromId;
  final String? initialToId;
  final String? initialValueQuery;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  late String _fromId;
  late String _toId;
  final _controller = TextEditingController();
  Timer? _debounce;
  double? _result;
  String? _error;
  String? _lastLoggedKey;

  ConversionCategory? get _category => categoryById(widget.categoryId);

  @override
  void initState() {
    super.initState();
    final units = unitsForCategory(widget.categoryId);
    _fromId = units.isEmpty ? '' : _pickFrom(units);
    _toId = units.isEmpty ? '' : _pickTo(units, _fromId);
    _controller.text = widget.initialValueQuery ?? '1';
    _controller.addListener(_onInputChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  String _pickFrom(List<UnitDefinition> units) {
    final w = widget.initialFromId;
    if (w != null && unitById(widget.categoryId, w) != null) return w;
    return units.first.id;
  }

  String _pickTo(List<UnitDefinition> units, String from) {
    final w = widget.initialToId;
    if (w != null && w != from && unitById(widget.categoryId, w) != null) return w;
    return units.firstWhere((u) => u.id != from, orElse: () => units.first).id;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onInputChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 140), _recompute);
  }

  void _recompute() {
    if (!mounted) return;
    final cat = _category;
    if (cat == null || unitsForCategory(widget.categoryId).isEmpty) {
      setState(() {
        _result = null;
        _error = 'Unknown category';
      });
      return;
    }
    final amount = tryParseAmount(_controller.text);
    if (amount == null) {
      setState(() {
        _result = null;
        _error = null;
      });
      return;
    }
    try {
      final out = cat.kind == ConversionCategoryKind.currency
          ? context.read<AppState>().currencyRates.convertSync(amount, _fromId, _toId)
          : convertCategorySync(widget.categoryId, amount, _fromId, _toId);
      setState(() {
        _result = out;
        _error = null;
      });
      _maybeLogRecent(amount, out);
    } catch (e) {
      setState(() {
        _result = null;
        _error = e.toString();
      });
    }
  }

  void _maybeLogRecent(double input, double out) {
    final key = '${widget.categoryId}|$_fromId|$_toId|$input';
    if (_lastLoggedKey == key) return;
    _lastLoggedKey = key;
    context.read<AppState>().addRecent(
          RecentConversion(
            categoryId: widget.categoryId,
            inputValue: input,
            fromUnitId: _fromId,
            toUnitId: _toId,
            result: out,
            timestampMillis: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  void _swap() {
    setState(() {
      final t = _fromId;
      _fromId = _toId;
      _toId = t;
    });
    _recompute();
  }

  @override
  Widget build(BuildContext context) {
    final cat = _category;
    final app = context.watch<AppState>();
    final units = unitsForCategory(widget.categoryId);
    if (cat == null || units.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Unknown category')));
    }
    final favorite = app.isFavorite(widget.categoryId, _fromId, _toId);
    final fromUnit = unitById(widget.categoryId, _fromId);
    final toUnit = unitById(widget.categoryId, _toId);

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.title),
        actions: [
          IconButton(
            icon: Icon(favorite ? Icons.star : Icons.star_border),
            onPressed: () => app.toggleFavorite(
              categoryId: widget.categoryId,
              fromUnitId: _fromId,
              toUnitId: _toId,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (cat.kind == ConversionCategoryKind.currency) ...[
            if (app.ratesRefreshing) const LinearProgressIndicator(minHeight: 3),
            _CurrencyStatusBanner(app: app),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(labelText: 'Amount', suffixText: fromUnit?.symbol),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _fromId,
                  decoration: const InputDecoration(labelText: 'From'),
                  items: [for (final u in units) DropdownMenuItem(value: u.id, child: Text('${u.name} (${u.symbol})'))],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _fromId = v);
                    _recompute();
                  },
                ),
              ),
              IconButton(onPressed: _swap, icon: const Icon(Icons.swap_vert)),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _toId,
                  decoration: const InputDecoration(labelText: 'To'),
                  items: [for (final u in units) DropdownMenuItem(value: u.id, child: Text('${u.name} (${u.symbol})'))],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _toId = v);
                    _recompute();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Result', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(
            _error ?? formatConverted(_result, app.decimalPlaces),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _error != null ? Theme.of(context).colorScheme.error : null,
                ),
          ),
          if (_result != null && toUnit != null) Text(toUnit.symbol),
        ],
      ),
    );
  }
}

/// Shows currency rate status with visual indicators for online/offline state
class _CurrencyStatusBanner extends StatelessWidget {
  const _CurrencyStatusBanner({required this.app});

  final AppState app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOffline = !app.isOnline;
    final isUsingFallback = app.isUsingFallbackRates;
    final isStale = app.ratesAreStale;

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    if (isOffline && isUsingFallback) {
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
      icon = Icons.cloud_off;
      message = 'Offline - Using approximate rates';
    } else if (isOffline) {
      backgroundColor = theme.colorScheme.secondaryContainer;
      textColor = theme.colorScheme.onSecondaryContainer;
      icon = Icons.cloud_off;
      message = 'Offline - ${app.ratesCacheAgeDescription}';
    } else if (isStale) {
      backgroundColor = theme.colorScheme.tertiaryContainer;
      textColor = theme.colorScheme.onTertiaryContainer;
      icon = Icons.update;
      message = '${app.ratesCacheAgeDescription} - Tap to refresh';
    } else {
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      icon = Icons.cloud_done;
      message = app.ratesCacheAgeDescription;
    }

    return GestureDetector(
      onTap: app.ratesRefreshing ? null : () => app.refreshCurrencyRates(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              ),
            ),
            if (!app.ratesRefreshing && (isOffline || isStale))
              Icon(Icons.refresh, size: 16, color: textColor),
          ],
        ),
      ),
    );
  }
}
