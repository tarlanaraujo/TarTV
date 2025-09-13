import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WakelockService extends ChangeNotifier {
  bool _enabled = true;
  bool get enabled => _enabled;

  WakelockService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('wakelock_enabled') ?? true;
    WakelockPlus.toggle(enable: _enabled);
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wakelock_enabled', value);
    WakelockPlus.toggle(enable: value);
    notifyListeners();
  }
}
