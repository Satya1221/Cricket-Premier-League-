import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Small persistence boundary for franchise state. Keeps Hive details out of UI.
class LocalStorageService {
  static const String boxName = 'game_state';
  static const String sessionKey = 'game_session';
  static const String preferencesKey = 'user_preferences';

  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  Future<void> saveSession(Map<String, Object?> state) =>
      _box.put(sessionKey, jsonEncode(state));

  Map<String, Object?>? loadSession() {
    final raw = _box.get(sessionKey);
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> savePreferences(Map<String, Object?> preferences) =>
      _box.put(preferencesKey, jsonEncode(preferences));

  Map<String, Object?>? loadPreferences() {
    final raw = _box.get(preferencesKey);
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> clearSession() => _box.delete(sessionKey);
}
