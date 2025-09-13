import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSettingsService extends ChangeNotifier {
  bool _autoplay = true;
  bool get autoplay => _autoplay;

  PlayerSettingsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _autoplay = prefs.getBool('autoplay') ?? true;
    notifyListeners();
  }

  Future<void> setAutoplay(bool value) async {
    _autoplay = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoplay', value);
    notifyListeners();
  }
}
