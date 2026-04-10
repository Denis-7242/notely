import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  // We store the theme preference in Hive so it persists
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Load the saved theme preference on startup
  Future<void> loadTheme() async {
    final box = await Hive.openBox(_boxName);
    _isDarkMode = box.get(_themeKey, defaultValue: false);
    notifyListeners();
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final box = Hive.box(_boxName);
    await box.put(_themeKey, _isDarkMode); // Persist the choice
    notifyListeners();
  }
}