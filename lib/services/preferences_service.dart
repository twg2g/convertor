import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _themeKey = 'theme_mode';
  static const _decimalsKey = 'decimal_places';
  static const _favoritesKey = 'favorites_json_v1';
  static const _recentsKey = 'recents_json_v1';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final s = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, s);
  }

  Future<int> getDecimalPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_decimalsKey) ?? 4;
  }

  Future<void> setDecimalPlaces(int n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_decimalsKey, n.clamp(0, 12));
  }

  Future<String?> getFavoritesRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_favoritesKey);
  }

  Future<void> setFavoritesRaw(String? raw) async {
    final prefs = await SharedPreferences.getInstance();
    if (raw == null || raw.isEmpty) {
      await prefs.remove(_favoritesKey);
    } else {
      await prefs.setString(_favoritesKey, raw);
    }
  }

  Future<String?> getRecentsRaw() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_recentsKey);
  }

  Future<void> setRecentsRaw(String? raw) async {
    final prefs = await SharedPreferences.getInstance();
    if (raw == null || raw.isEmpty) {
      await prefs.remove(_recentsKey);
    } else {
      await prefs.setString(_recentsKey, raw);
    }
  }
}
