import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/career_simulation_engine.dart';

/// JSON-backed Hive persistence; no generated adapters are required.
class CareerSaveRepository {
  static const String boxName = 'career_saves';
  Box<dynamic> get _box => Hive.box<dynamic>(boxName);

  Future<void> saveSeason(String saveId, SeasonData season) async {
    await _box.put(saveId, jsonEncode(season.toJson()));
  }

  SeasonData? loadSeason(String saveId) {
    final raw = _box.get(saveId);
    if (raw is! String) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return SeasonData.fromJson(Map<String, Object?>.from(decoded));
  }

  static const String historyBoxName = 'history_records';
  Box<dynamic> get _historyBox => Hive.box<dynamic>(historyBoxName);

  Future<void> saveHistory(String seasonKey, Map<String, Object?> snapshot) =>
      _historyBox.put(seasonKey, jsonEncode(snapshot));

  Map<String, Object?>? loadHistory(String seasonKey) {
    final raw = _historyBox.get(seasonKey);
    if (raw is! String) return null;
    final decoded = jsonDecode(raw);
    return decoded is Map ? Map<String, Object?>.from(decoded) : null;
  }

  List<String> get historyKeys => _historyBox.keys.whereType<String>().toList()..sort();

  List<String> get saveIds => _box.keys.whereType<String>().toList()..sort();

  Future<void> deleteSave(String saveId) => _box.delete(saveId);
}
