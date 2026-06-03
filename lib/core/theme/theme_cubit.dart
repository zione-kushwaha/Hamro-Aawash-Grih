import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final stored = prefs.getString(AppConstants.themeKey);
    switch (stored) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setLight() => _save(ThemeMode.light);
  void setDark() => _save(ThemeMode.dark);
  void setSystem() => _save(ThemeMode.system);

  void _save(ThemeMode mode) {
    emit(mode);
    _prefs.setString(AppConstants.themeKey, mode.name);
  }
}
