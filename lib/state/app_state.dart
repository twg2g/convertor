import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/favorite_conversion.dart';
import '../models/recent_conversion.dart';
import '../services/currency_rates_repository.dart';
import '../services/preferences_service.dart';

class AppState extends ChangeNotifier {
  AppState({required this.preferences, required this.currencyRates});

  final PreferencesService preferences;
  final CurrencyRatesRepository currencyRates;

  ThemeMode _themeMode = ThemeMode.system;
  int _decimalPlaces = 4;
  final List<FavoriteConversion> _favorites = [];
  final List<RecentConversion> _recents = [];
  bool _ratesRefreshing = false;
  String? _ratesError;

  ThemeMode get themeMode => _themeMode;
  int get decimalPlaces => _decimalPlaces;
  List<FavoriteConversion> get favorites => List.unmodifiable(_favorites);
  List<RecentConversion> get recents => List.unmodifiable(_recents);
  bool get ratesRefreshing => _ratesRefreshing;
  String? get ratesError => _ratesError;

  Future<void> bootstrap() async {
    _themeMode = await preferences.getThemeMode();
    _decimalPlaces = await preferences.getDecimalPlaces();
    _loadJsonList(
      await preferences.getFavoritesRaw(),
      (m) => FavoriteConversion.fromJson(m),
      _favorites,
    );
    _loadJsonList(
      await preferences.getRecentsRaw(),
      (m) => RecentConversion.fromJson(m),
      _recents,
    );
    notifyListeners();
    await refreshCurrencyRates();
  }

  void _loadJsonList<T>(
    String? raw,
    T? Function(Map<String, dynamic>) parse,
    List<T> target,
  ) {
    target.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final item = parse(Map<String, dynamic>.from(e as Map));
        if (item != null) target.add(item);
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await preferences.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int n) async {
    _decimalPlaces = n.clamp(0, 12);
    await preferences.setDecimalPlaces(_decimalPlaces);
    notifyListeners();
  }

  Future<void> refreshCurrencyRates() async {
    _ratesRefreshing = true;
    _ratesError = null;
    notifyListeners();
    try {
      await currencyRates.refreshFromNetwork();
    } catch (e) {
      _ratesError = e.toString();
    } finally {
      _ratesRefreshing = false;
      notifyListeners();
    }
  }

  bool isFavorite(String categoryId, String from, String to) {
    return _favorites.any((f) => f.categoryId == categoryId && f.fromUnitId == from && f.toUnitId == to);
  }

  Future<void> toggleFavorite({
    required String categoryId,
    required String fromUnitId,
    required String toUnitId,
  }) async {
    final idx = _favorites.indexWhere(
      (f) => f.categoryId == categoryId && f.fromUnitId == fromUnitId && f.toUnitId == toUnitId,
    );
    if (idx >= 0) {
      _favorites.removeAt(idx);
    } else {
      _favorites.add(
        FavoriteConversion(
          categoryId: categoryId,
          fromUnitId: fromUnitId,
          toUnitId: toUnitId,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
    await preferences.setFavoritesRaw(jsonEncode(_favorites.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> removeFavorite(FavoriteConversion f) async {
    _favorites.removeWhere(
      (x) => x.categoryId == f.categoryId && x.fromUnitId == f.fromUnitId && x.toUnitId == f.toUnitId,
    );
    await preferences.setFavoritesRaw(jsonEncode(_favorites.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addRecent(RecentConversion r) async {
    _recents.removeWhere(
      (x) =>
          x.categoryId == r.categoryId &&
          x.fromUnitId == r.fromUnitId &&
          x.toUnitId == r.toUnitId &&
          x.inputValue == r.inputValue,
    );
    _recents.insert(0, r);
    while (_recents.length > 20) {
      _recents.removeLast();
    }
    await preferences.setRecentsRaw(jsonEncode(_recents.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> clearRecents() async {
    _recents.clear();
    await preferences.setRecentsRaw(null);
    notifyListeners();
  }
}
