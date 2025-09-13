import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettingsService extends ChangeNotifier {
  String _quality = 'Auto';
  int _gridColumns = 2;

  String get quality => _quality;
  int get gridColumns => _gridColumns;

  DisplaySettingsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _quality = prefs.getString('display_quality') ?? 'Auto';
    _gridColumns = prefs.getInt('display_grid_columns') ?? 2;
    notifyListeners();
  }

  Future<void> setQuality(String value) async {
    _quality = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_quality', value);
    notifyListeners();
  }

  Future<void> setGridColumns(int value) async {
    _gridColumns = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('display_grid_columns', value);
    notifyListeners();
  }
}
