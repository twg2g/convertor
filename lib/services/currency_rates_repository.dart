import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyRatesRepository {
  static const _prefsKey = 'currency_rates_cache_v1';
  static const _prefsTimeKey = 'currency_rates_cache_time_v1';
  static const _base = 'USD';
  
  /// How old cached rates can be before auto-refresh is attempted
  static const _staleThreshold = Duration(hours: 1);
  
  /// Fallback rates used when no cache exists and network is unavailable.
  /// These approximate rates allow offline use on first launch.
  /// Last updated: May 2025
  static const _fallbackRates = <String, double>{
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 154.50,
    'CHF': 0.90,
    'CNY': 7.24,
    'ZMW': 27.50,
    'CAD': 1.36,
    'AUD': 1.53,
    'INR': 83.50,
    'BRL': 5.05,
    'ZAR': 18.20,
    'NGN': 1550.0,
    'KES': 129.0,
  };

  Map<String, double> _memoryRates = {};
  DateTime? _memoryFetchedAt;
  bool _isUsingFallback = false;
  bool _isOnline = true;

  Map<String, double> get lastRates => Map.unmodifiable(_memoryRates);
  DateTime? get lastFetchedAt => _memoryFetchedAt;
  bool get isUsingFallback => _isUsingFallback;
  bool get isOnline => _isOnline;
  
  /// Returns true if the cached rates are older than the stale threshold
  bool get isStale {
    if (_memoryFetchedAt == null) return true;
    return DateTime.now().difference(_memoryFetchedAt!) > _staleThreshold;
  }
  
  /// Returns a human-readable string describing the cache age
  String get cacheAgeDescription {
    if (_isUsingFallback) return 'Using offline fallback rates';
    if (_memoryFetchedAt == null) return 'No rates available';
    final diff = DateTime.now().difference(_memoryFetchedAt!);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    return 'Updated ${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  }

  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    final t = prefs.getInt(_prefsTimeKey);
    if (raw == null || t == null) {
      // No cached rates - use fallback for offline-first support
      _memoryRates = Map.from(_fallbackRates);
      _isUsingFallback = true;
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _memoryRates = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
      _memoryFetchedAt = DateTime.fromMillisecondsSinceEpoch(t);
      _isUsingFallback = false;
    } catch (_) {
      _memoryRates = Map.from(_fallbackRates);
      _isUsingFallback = true;
      _memoryFetchedAt = null;
    }
  }

  /// Attempts to refresh rates from the network.
  /// Returns true if successful, false if offline/failed.
  /// On failure, existing cached or fallback rates remain available.
  Future<bool> refreshFromNetwork() async {
    try {
      final uri = Uri.parse('https://api.frankfurter.app/latest?from=$_base');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        _isOnline = false;
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
      _isUsingFallback = false;
      _isOnline = true;
      
      // Persist to disk for offline use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_memoryRates));
      await prefs.setInt(_prefsTimeKey, _memoryFetchedAt!.millisecondsSinceEpoch);
      return true;
    } catch (e) {
      _isOnline = false;
      // Keep existing rates (cached or fallback) - don't throw
      if (_memoryRates.isEmpty) {
        _memoryRates = Map.from(_fallbackRates);
        _isUsingFallback = true;
      }
      rethrow;
    }
  }
  
  /// Refreshes only if rates are stale. Silently fails if offline.
  Future<void> refreshIfStale() async {
    if (!isStale) return;
    try {
      await refreshFromNetwork();
    } catch (_) {
      // Silently fail - we have cached/fallback rates
    }
  }

  double convertSync(double amount, String from, String to) {
    if (from == to) return amount;
    if (_memoryRates.isEmpty) {
      // Last resort: use fallback rates
      _memoryRates = Map.from(_fallbackRates);
      _isUsingFallback = true;
    }
    final rf = _memoryRates[from];
    final rt = _memoryRates[to];
    if (rf == null || rt == null || rf == 0) {
      throw ArgumentError('Missing rate for $from or $to');
    }
    return amount / rf * rt;
  }
}
