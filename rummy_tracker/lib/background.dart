import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService extends ChangeNotifier {
  static const _key = 'app_background';
  static const _backgrounds = {
    4: 'game_night',
    5: 'burgundy_club',
    1: 'emerald_felt',
    3: 'modern_midnight',
  };
  int _selected = 4;
  bool _changed = false;
  bool _disposed = false;

  BackgroundService() {
    _load();
  }

  String get assetPath => 'assets/images/${_backgrounds[_selected]}.webp';
  String get nameKey => 'background_${_backgrounds[_selected]}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.get(_key);
    if (_disposed || _changed || !_backgrounds.containsKey(saved)) return;
    _selected = saved as int;
    notifyListeners();
  }

  Future<void> next() async {
    final choices = _backgrounds.keys.toList();
    _selected = choices[(choices.indexOf(_selected) + 1) % choices.length];
    _changed = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _selected);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
