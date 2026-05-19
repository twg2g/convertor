import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyRatesRepository {
  static const _prefsKey = 'currency_rates_cache_v1';
  static const _prefsTimeKey = 'currency_rates_cache_time_v1';
  static const _base = 'USD';

  Map<String, double> _memoryRates = {};
  DateTime? _memoryFetchedAt;

  Map<String, double> get lastRates => Map.unmodifiable(_memoryRates);
  DateTime? get lastFetchedAt => _memoryFetchedAt;

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final t = prefs.getInt(_prefsTimeKey);
    if (raw == null || t == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _memoryRates = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
      _memoryFetchedAt = DateTime.fromMillisecondsSinceEpoch(t);
    } catch (_) {
      _memoryRates = {};
      _memoryFetchedAt = null;
    }
  }

  Future<void> refreshFromNetwork() async {
    final uri = Uri.parse('https://api.frankfurter.app/latest?from=$_base');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Currency API failed (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final rates = body['rates'] as Map<String, dynamic>? ?? {};
    final next = <String, double>{_base: 1.0};
    for (final e in rates.entries) {
      next[e.key] = (e.value as num).toDouble();
    }
    _memoryRates = next;
    _memoryFetchedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_memoryRates));
    await prefs.setInt(_prefsTimeKey, _memoryFetchedAt!.millisecondsSinceEpoch);
  }

  double convertSync(double amount, String from, String to) {
    if (from == to) return amount;
    if (_memoryRates.isEmpty) {
      throw StateError('No cached currency rates. Connect once or refresh.');
    }
    final rf = _memoryRates[from];
    final rt = _memoryRates[to];
    if (rf == null || rt == null || rf == 0) {
      throw ArgumentError('Missing rate for $from or $to');
    }
    return amount / rf * rt;
  }
}
