import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeBloc extends Cubit<ThemeMode> {
  static const String _themeKey = 'theme_mode';
  final SharedPreferences prefs;

  ThemeBloc(this.prefs) : super(_loadTheme(prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final themeStr = prefs.getString(_themeKey);
    if (themeStr == 'dark') return ThemeMode.dark;
    if (themeStr == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }
}
