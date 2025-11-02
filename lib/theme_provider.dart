// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   static const Color _defaultSeed = Color(0xFF1A003C);
//
//   ThemeMode _themeMode = ThemeMode.system;
//   Color _seedColor = _defaultSeed;
//   bool _useDefaultSeed = true;
//
//   ThemeMode get themeMode => _themeMode;
//   Color get seedColor => _seedColor;
//   bool get useDefaultSeed => _useDefaultSeed;
//
//   void setTheme(ThemeMode mode) {
//     _themeMode = mode;
//     notifyListeners();
//   }
//
//   void setSeedColor(Color color) {
//     _seedColor = color;
//     _useDefaultSeed = false;
//     notifyListeners();
//   }
//
//   void resetToDefaultSeed() {
//     _seedColor = _defaultSeed;
//     _useDefaultSeed = true;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  static const Color _defaultSeed = Color(0xFF1A003C);

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = _defaultSeed;
  bool _useDefaultSeed = true;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get useDefaultSeed => _useDefaultSeed;

  /// Load theme settings from Hive
  Future<void> loadFromHive(Box box) async {
    final modeIndex = box.get('themeMode', defaultValue: ThemeMode.system.index);
    _themeMode = ThemeMode.values[modeIndex];

    final seedValue = box.get('seedColor', defaultValue: _defaultSeed.value);
    _seedColor = Color(seedValue);

    _useDefaultSeed = box.get('useDefaultSeed', defaultValue: true);

    notifyListeners();
  }

  /// Save current theme settings to Hive
  Future<void> saveToHive(Box box) async {
    await box.put('themeMode', _themeMode.index);
    await box.put('seedColor', _seedColor.value);
    await box.put('useDefaultSeed', _useDefaultSeed);
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    _useDefaultSeed = false;
    notifyListeners();
  }

  void resetToDefaultSeed() {
    _seedColor = _defaultSeed;
    _useDefaultSeed = true;
    notifyListeners();
  }
}
